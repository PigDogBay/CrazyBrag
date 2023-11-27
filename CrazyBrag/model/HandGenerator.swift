//
//  HandGenerator.swift
//  CardGames
//
//  Created by Mark Bailey on 06/10/2022.
//

import Foundation

struct HandGenerator {
    let playerHand : PlayerHand
    
    private func createdScoredTurn(_ middle : PlayerHand, _ playerCard : PlayingCard,_ middleCard : PlayingCard) -> ScoredTurn {
        let possibleHand = PlayerHand(hand: playerHand.hand)
        possibleHand.replace(cardInHand: playerCard, with: middleCard)
        
        let possibleMiddle = PlayerHand(hand: middle.hand)
        possibleMiddle.replace(cardInHand: middleCard, with: playerCard)
        
        return ScoredTurn(turn: .swap(hand: playerCard, middle: middleCard),
                          score: possibleHand.score, middleScore: possibleMiddle.score)
    }

    func generatePossibleTurns(middle : PlayerHand) -> [ScoredTurn] {
        var turns = [ScoredTurn]()
        playerHand.hand.forEach{ playerCard in
            middle.hand.forEach{middleCard in
                turns.append(createdScoredTurn(middle, playerCard, middleCard))
            }
        }
        //Finally swap all 3
        turns.append(ScoredTurn(turn: .all(), score: middle.score, middleScore: playerHand.score))
        return turns
    }
    
    ///Hand generator for the 1 down in middle variation
    ///This will not consider the unknown card in the middle that is facedown
    func generatePossibleTurnsFaceUpOnly(middle : PlayerHand) -> [ScoredTurn] {
        var turns = [ScoredTurn]()
        playerHand.hand.forEach{ playerCard in
            middle.hand
                //First card is face down, so ignore it
                .dropFirst()
                .forEach{ middleCard in
                    //No peeping at middle score!
                    turns.append(createdScoredTurn(middle, playerCard, middleCard))
                }
        }
        return turns
    }
    
    ///When the player has to take the face down middle card, which is the best card to throw in?
    private func createdScoredTurnUsingDownCard(_ middle : PlayerHand, indexToSwap : Int) -> ScoredTurn {
        //Player hand's throw in the card at indexToSwap, face down
        let swapped = playerHand.hand[indexToSwap]
        //Get remaining two cards in the hand
        let hand = playerHand.hand.filter{$0 != swapped}
        //What's the best possible score with this hand
        let resolver = PossibleHandResolver(hand: hand)
        let score = resolver.createScore()

        //Generate the result for comparison
        let turn = Turn.swap(hand: swapped, middle: middle.hand[0])
        let middleScore = PossibleHandResolver(hand: [middle.hand[1],middle.hand[2]]).createScore()
        return ScoredTurn(turn: turn, score: score, middleScore: middleScore)
    }
    
    ///Whats the score if player takes all the cards, this calculates the score of the hand in the player will
    ///place in the middle
    ///downIndex: - index of card in the player's hand to place face down
    private func createAllInOneDown(_ middleScore : BragHandScore, downIndex : Int) -> ScoredTurn {
        let turn = Turn.all(downIndex: downIndex)
        let downCard = playerHand.hand[downIndex]
        //Calculate the possible middle score when the player throws in all of their hand
        let faceUpCards = playerHand.hand.filter{$0 != downCard}
        let resolver = PossibleHandResolver(hand: faceUpCards)
        let score = resolver.createScore()
        return ScoredTurn(turn: turn, score: middleScore, middleScore: score)
    }
    
    func generatePotentialHands(middle : PlayerHand) -> [ScoredTurn] {
        var turns = [ScoredTurn]()
        for i in 0...2 {
            let scoredTurn = createdScoredTurnUsingDownCard(middle, indexToSwap: i)
            turns.append(scoredTurn)
            //All In, generate a potential score for the middle (maybe the AI will want to bait?)
            //The potential hand score will be the current middle score
            turns.append(createAllInOneDown(scoredTurn.middleScore, downIndex: i))
        }
        return turns
    }

}
