//
//  AI.swift
//  CardGames
//
//  Created by Mark Bailey on 29/09/2022.
//

import Foundation

protocol AI : AnyObject {
    var player : Player? { get set }
    func play(middle : PlayerHand) -> Turn
}

class HumanAI : AI {
    var player: Player?
    var turn : Turn?
    
    func play(middle: PlayerHand) -> Turn {
        return turn!
    }
}

class RandomAI : AI{
    weak var player: Player?
    
    func play(middle: PlayerHand) -> Turn {
        return HandGenerator(playerHand: player!.hand)
            .generatePossibleTurns(middle: middle)
            .randomElement()!
            .turn
    }
}

class BestAI : AI {
    weak var player: Player?

    func play(middle: PlayerHand) -> Turn {
        return HandGenerator(playerHand: player!.hand)
            .generatePossibleTurns(middle: middle)
            .max(by: {$0.score < $1.score})!
            .turn
    }
}

class PrialChuckerAI : AI {
    weak var player: Player?
    private let school : School
    private let lowHand = [PlayingCard(suit: .clubs, rank: .two),
                           PlayingCard(suit: .diamonds, rank: .eight),
                           PlayingCard(suit: .hearts, rank: .eight)]

    private let lowestScoreToConsiderPrial : Int

    init(school : School){
        self.school = school
        lowestScoreToConsiderPrial = PlayerHand(hand: lowHand).score.score
    }

    func bestTurn(middle: PlayerHand) -> ScoredTurn {
        return HandGenerator(playerHand: player!.hand)
            .generatePossibleTurns(middle: middle)
            .max(by: {$0.score < $1.score})!
    }

    func play(middle: PlayerHand) -> Turn {
        let best = bestTurn(middle: middle)
        let prialInMiddle = HandGenerator(playerHand: player!.hand)
            .generatePossibleTurns(middle: middle)
            .filter{$0.middleScore.type == .prial}
            .first
        if let prialInMiddle = prialInMiddle {
            if school.players.count>2 && best.score.score < lowestScoreToConsiderPrial {
                return prialInMiddle.turn
            }
        }
        return best.turn
    }

}

