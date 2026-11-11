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
        //Keep the good joker out of sight
        if let jokerIndex = player!.hand.hand.firstIndex(of: PlayingCard.goodJoker) {
            return Turn.all(downIndex: jokerIndex)
        }
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
        
        let holdsGoodJoker = player!.hand.hand.contains(PlayingCard.goodJoker)
        if holdsGoodJoker && bestScoreFaceUp.score.type > .pair {
            //With the good joker a swap can still leave a flush or a run, better than gambling on the down card
            return nil
        }

        //is there a chance of a better prial in the middle?
        //resolverPlayer.hand is the prial as scored, with the good joker played as the third card
        if let showing = pairShowing(middle: middle),
           showing.score() > resolverPlayer.hand[0].rank.score(){
            return createTakeAllTurn()
        }
        //TODO consider playing a card with the same suit as one of the middle cards
        //Hang on to the good joker
        let swapCard = player!.hand.hand.first(where: {$0 != PlayingCard.goodJoker})!
        return .swap(hand: swapCard, middle: middle.hand[0])
    }
    
    ///The rank of the pair showing in the middle, the good joker pairs up with the card next to it
    private func pairShowing(middle: PlayerHand) -> Rank? {
        let c1 = middle.hand[1]
        let c2 = middle.hand[2]
        if c1 == PlayingCard.goodJoker {
            return c2.isJoker ? nil : c2.rank
        }
        if c2 == PlayingCard.goodJoker {
            return c1.isJoker ? nil : c1.rank
        }
        return c1.rank == c2.rank && !c1.isJoker ? c1.rank : nil
    }

    private func pairInTheMiddle(middle: PlayerHand, bestScoreFaceUp : ScoredTurn) -> Turn? {
        guard let showing = pairShowing(middle: middle) else {
            //no pair is showing
            return nil
        }
        if player!.hand.hand.contains(PlayingCard.goodJoker) {
            //Don't throw the good joker in, swapping a card will do just as well
            return nil
        }
        if middle.hand.dropFirst().contains(PlayingCard.goodJoker) &&
            bestScoreFaceUp.score.type == .pair &&
            (bestScoreFaceUp.score.score >> 16) & 0xff >= showing.score() {
            //The good joker is showing, picking it up on its own makes as good a pair as taking all three
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
            resolverPlayer.hand[1].rank.score() > showing.score() {
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
        //The good joker is half of the pair, so it stays
        if let swapCard = player?.hand.hand.first(where: {$0.rank != pairRank && $0 != PlayingCard.goodJoker}) {
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
