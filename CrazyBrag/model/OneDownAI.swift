//
//  OneDownAI.swift
//  CardGames
//
//  Created by Mark Bailey on 06/10/2022.
//

import Foundation
class OneDownAI : AI {
    weak var player: Player?

    func play(middle: PlayerHand) -> Turn {
        let scoredTurn = HandGenerator(playerHand: player!.hand)
            .generatePossibleTurnsFaceUpOnly(middle: middle)
            .max(by: {$0.score < $1.score})!

        if let turn = playerHoldsAPrial(middle: middle, bestScoreFaceUp: scoredTurn){
            return turn
        }
        if let turn = pairInTheMiddle(middle: middle, bestScoreFaceUp: scoredTurn){
            return turn
        }
        //If have a pair in the hand, maybe try for a prial?
        if let turn = tryForPrial(middle: middle, bestScoreFaceUp: scoredTurn){
            return turn
        }
        if let turn = tryForAGoodHand(middle: middle, bestScoreFaceUp: scoredTurn){
            return turn
        }
        return scoredTurn.turn
    }
    
    private func tryForAGoodHand(middle: PlayerHand, bestScoreFaceUp : ScoredTurn) -> Turn? {
        if bestScoreFaceUp.score.type != .high {
            return nil
        }
        
        let generator = HandGenerator(playerHand: player!.hand)
        let potentialTurn = generator
            .generatePotentialHands(middle: middle)
            .max(by: {$0.score < $1.score})!
        
        if potentialTurn.score.type >= BragHandTypes.flush {
            return potentialTurn.turn
        }
        return nil
    }
    
    private func createTakeAllTurn() -> Turn{
        let c1 = player!.hand.hand[0]
        let c2 = player!.hand.hand[1]
        let c3 = player!.hand.hand[2]
        //Bait: if the player is throwing a pair in, show them
        if c1.rank == c2.rank {
            return Turn.all(downIndex: 2)
        }
        if c1.rank == c3.rank {
            return Turn.all(downIndex: 1)
        }
        if c2.rank == c3.rank {
            return Turn.all(downIndex: 0)
        }
        //if player has cards with same suit, show them to lesser chance of other
        //players getting a flush
        if c1.suit == c2.suit {
            return Turn.all(downIndex: 2)
        }
        if c1.suit == c3.suit {
            return Turn.all(downIndex: 1)
        }
        if c2.suit == c3.suit {
            return Turn.all(downIndex: 0)
        }
        return Turn.all(downIndex: 0)
    }
    
    //The player has a prial in their hand, unless the same rank is showing
    //should try the middle card
    private func playerHoldsAPrial(middle: PlayerHand, bestScoreFaceUp : ScoredTurn) -> Turn? {
        if bestScoreFaceUp.score.type == .prial {
            //player can still make a prial with one of the face up cards
            return nil
        }
        
        //Does the player hold a prial
        let resolverPlayer = HandResolver(hand: player!.hand.hand)
        let currentScore = resolverPlayer.createScore()
        if currentScore.type != .prial {
            //player does not hold a prial
            return nil
        }
        
        //is there a chance of a better prial in the middle?
        if middle.hand[1].rank == middle.hand[2].rank &&
            middle.hand[1].rank.score() > player!.hand.hand[0].rank.score(){
            return createTakeAllTurn()
        }
        //TODO consider playing a card with the same suit as one of the middle cards
        return .swap(hand: player!.hand.hand[0], middle: middle.hand[0])
    }
    
    private func pairInTheMiddle(middle: PlayerHand, bestScoreFaceUp : ScoredTurn) -> Turn? {
        if middle.hand[1].rank != middle.hand[2].rank {
            //no pair is showing
            return nil
        }
        if bestScoreFaceUp.score.type > .pair {
            //A better hand is available using the face up cards
            return nil
        }
        
        //Does the player hold a better pair?
        let resolverPlayer = HandResolver(hand: player!.hand.hand)
        let currentScore = resolverPlayer.createScore()
        if currentScore.type == .pair &&
            resolverPlayer.hand[1].rank.score() > middle.hand[1].rank.score() {
            return nil
        }
        return createTakeAllTurn()
    }

    ///If player has a pair in their hand, try for the middle
    ///if there is not a better pair or hand using the face up cards
    private func tryForPrial(middle: PlayerHand, bestScoreFaceUp : ScoredTurn) -> Turn? {
        //First check that a pair is the best score using the down cards
        //If you have a pair in the hand and can not improve the hand, then
        //bestScoreFaceUp is a pair
        if bestScoreFaceUp.score.type != .pair {
            return nil
        }
        //Does the player have a pair in their hand
        let resolverPlayer = HandResolver(hand: player!.hand.hand)
        let currentScore = resolverPlayer.createScore()
        if currentScore.type != .pair{
            //bestScoreFaceUp is a turn that gets the player a pair
            return nil
        }

        if HandResolver.removeHighScoreFromPair(score: currentScore.score) !=
            HandResolver.removeHighScoreFromPair(score: bestScoreFaceUp.score.score){
            //bestScoreFaceUp is a better pair
            return nil
        }
        
        //Ok lets go for a prial, first need to find which card is not in the pair
        let pairRank = resolverPlayer.pairRank
        if let swapCard = player?.hand.hand.first(where: {$0.rank != pairRank}) {
            //First card in the middle is down
            return Turn.swap(hand: swapCard, middle: middle.hand[0])
        }
        //BUG: shouldn't reach here
#if DEBUG
        fatalError("Oops")
#else
        return nil
#endif
    }
}
