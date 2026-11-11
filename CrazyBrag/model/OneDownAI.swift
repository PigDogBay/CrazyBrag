//
//  OneDownAI.swift
//  CardGames
//
//  Created by Mark Bailey on 06/10/2022.
//

import Foundation
class OneDownAI : AI {
    weak var player: Player?
    ///Looky Looky rules: does this player take the optional actions before making their move
    var usesActions = true
    ///Looky Looky rules: the face down middle card, once the player has looked at it this turn
    private var lookedAtCard : PlayingCard? = nil

    func play(middle: PlayerHand) -> Turn {
        let turn = decideTurn(middle: middle)
        lookedAtCard = nil
        return turn
    }

    func lookedAt(card: PlayingCard) {
        lookedAtCard = card
    }

    ///True if the player has looked at the face down card and it is still the one in the middle
    private func knowsDownCard(middle: PlayerHand) -> Bool {
        return lookedAtCard != nil && lookedAtCard == middle.hand.first
    }

    ///The highest scoring turn from what the player can see: the face up cards,
    ///and the face down card as well once they have looked at it
    private func bestVisibleTurn(middle: PlayerHand) -> ScoredTurn {
        let generator = HandGenerator(playerHand: player!.hand)
        let turns = knowsDownCard(middle: middle)
            ? generator.generatePossibleTurns(middle: middle)
            : generator.generatePossibleTurnsFaceUpOnly(middle: middle)
        return turns.max(by: {$0.score < $1.score})!
    }

    ///Two cards that could become a flush, run, trotter or prial with the right third card
    private func isPromising(_ card1 : PlayingCard, _ card2 : PlayingCard) -> Bool {
        return PossibleHandResolver(hand: [card1, card2]).createScore().type >= .flush
    }

    ///Does the hand hold two cards that work together (or the good joker, which works with anything)
    private func isPromising(hand : [PlayingCard]) -> Bool {
        return isPromising(hand[0], hand[1]) || isPromising(hand[0], hand[2]) || isPromising(hand[1], hand[2])
    }

    /**
     Looky Looky rules, which action to take next, if any:
     - Stash a hand that is going nowhere straightaway: no two cards work together and the cards showing don't help
     - Looky if the hand is promising but the cards showing don't complete it (this covers holding a pair
       and hoping for the prial), or if the two cards showing are promising themselves
     - Stash the hand if all of the middle is going to be taken anyway, there is nothing to lose
     - Change a middle card: out of spite if good cards are being left for the next player,
       or swap a useless card for a new one that might hit a promising hand
     */
    func chooseAction(middle: PlayerHand, available: [TurnAction]) -> ActionChoice? {
        guard usesActions, !available.isEmpty,
              let hand = player?.hand.hand, hand.count == 3, middle.hand.count == 3 else {
            return nil
        }
        let best = bestVisibleTurn(middle: middle)
        let promising = isPromising(hand: hand)
        let showing1 = middle.hand[1]
        let showing2 = middle.hand[2]
        let promisingMiddle = isPromising(showing1, showing2)

        if available.contains(.stashHand) && !promising && best.score.type < .pair {
            return .stashHand
        }
        if available.contains(.looky) && !knowsDownCard(middle: middle)
            && best.score.type < .run && (promising || promisingMiddle) {
            return .looky
        }
        let turn = decideTurn(middle: middle)
        if case .all = turn {
            //The hand is going in the middle, a new one might be better and if not the middle is still there
            return available.contains(.stashHand) ? .stashHand : nil
        }
        if available.contains(.changeMiddle) {
            //The middle card that is wanted, if it makes a hand
            var taking : PlayingCard? = nil
            if case .swap(hand: _, middle: let middleCard) = turn, best.score.type >= .pair {
                taking = middleCard
            }
            //The higher card is more use to the other players
            let highestShowing = showing1.rank.score() >= showing2.rank.score() ? showing1 : showing2
            if promisingMiddle && taking != showing1 && taking != showing2
                && PossibleHandResolver(hand: [showing1, showing2]).createScore().type >= .trotter {
                //Spite: a pair or two cards of a trotter are showing, don't leave them for the next player
                return .changeMiddle(card: highestShowing)
            }
            if promising && best.score.type <= .pair {
                //Nothing in the middle hits the hand, try a new card in place of one that is no use
                if taking == showing1 {
                    return .changeMiddle(card: showing2)
                }
                if taking == showing2 {
                    return .changeMiddle(card: showing1)
                }
                return .changeMiddle(card: highestShowing)
            }
        }
        return nil
    }

    private func decideTurn(middle: PlayerHand) -> Turn {
        if knowsDownCard(middle: middle) {
            //Looky Looky rules: all of the middle is known, so take the best hand on offer
            let best = bestVisibleTurn(middle: middle)
            if case .all = best.turn {
                return createTakeAllTurn()
            }
            return best.turn
        }
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
