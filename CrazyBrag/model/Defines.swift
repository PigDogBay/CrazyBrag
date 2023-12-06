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

struct DealtCard {
    var isMiddle : Bool { seat<0}
    let seat : Int
    let card : PlayingCard
    ///1-first card, 2 = second card or 3 last card dealt to player/middle
    let cardCount : Int
    
    var zPosition : CGFloat {
        switch cardCount {
        case 1 : return Layer.card1.rawValue
        case 2 : return Layer.card2.rawValue
        default : return Layer.card3.rawValue
        }
    }
    
    ///When dealing to a player, call this initialiser
    init(seat: Int, card: PlayingCard, cardCount: Int) {
        self.seat = seat
        self.card = card
        self.cardCount = cardCount
    }
    
    ///When dealing to the middle, call this initialiser
    init(card: PlayingCard, cardCount: Int) {
        self.seat = -1
        self.card = card
        self.cardCount = cardCount
    }
}
