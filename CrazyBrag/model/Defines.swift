//
//  Defines.swift
//  CardGames
//
//  Created by Mark Bailey on 05/10/2022.
//

import Foundation

enum CardErrors : Error {
    case CardAlreadyInThePack(card : PlayingCard)
}

enum BragHandTypes : Equatable, Comparable {
    case high, pair, flush, run, trotter, prial
    
    func display() -> String {
        switch self {
        case .high:
            return "High"
        case .pair:
            return "Pair"
        case .flush:
            return "Flush"
        case .run:
            return "Run"
        case .trotter:
            return "Trotter"
        case .prial:
            return "Prial"
        }
    }
}

struct BragHandScore : Comparable, Equatable {
    let type : BragHandTypes
    let score : Int

    static func < (lhs: BragHandScore, rhs: BragHandScore) -> Bool {
        return lhs.score < rhs.score
    }
    
    func display() -> String {
        return type.display() + " \(score)"
    }

}

///Player can swap one card with the middle or all 3
enum Turn : Equatable {
    case swap(hand : PlayingCard, middle : PlayingCard)
    case all(downIndex : Int = -1)
    
    func display() -> String {
        switch self {
        case .swap(hand: let hand, middle: let middle):
            return "Swap \(hand.display()) for \(middle.display())"
        case .all:
            return "All"
        }
    }
}

struct ScoredTurn {
    let turn : Turn
    let score : BragHandScore
    let middleScore : BragHandScore
    func display() -> String {
        return "\(turn.display()) score: \(score.display()), middle: \(middleScore.display())"
    }
}

