//
//  PlayingCard.swift
//  CardGames
//
//  Created by Mark Bailey on 09/09/2022.
//

import Foundation

enum Suit : Int, CaseIterable {
    case clubs, diamonds, hearts, spades
    ///The jokers are not in any of the four suits
    case joker
    
    ///The four suits of a standard pack
    static let standard : [Suit] = [.clubs, .diamonds, .hearts, .spades]

    func display() -> String  {
        switch self {
        case .joker:
            return "🃏"
        case .clubs:
            return "♣️"
        case .diamonds:
            return "♦️"
        case .hearts:
            return "❤️"
        case .spades:
            return "♠️"
        }
    }
    
    static func unflatten(flattened: String) -> Suit? {
        switch flattened.lowercased() {
        case "h": return .hearts
        case "c": return .clubs
        case "d": return .diamonds
        case "s": return .spades
        default: return nil
        }
    }
}

enum Rank : Int, CaseIterable {
    case ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    ///The jokers, kept after the thirteen standard ranks so their raw values are unchanged
    case goodJoker, badJoker
    
    ///The thirteen ranks of a standard pack
    static let standard : [Rank] = [.ace, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king]

    var isJoker : Bool {
        return self == .goodJoker || self == .badJoker
    }

    func display() -> String  {
        switch self {
        case .goodJoker:
            return "Good"
        case .badJoker:
            return "Bad"
        case .ace:
            return "A"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .ten:
            return "10"
        case .jack:
            return "J"
        case .queen:
            return "Q"
        case .king:
            return "K"
        }
    }
    
    ///Ace high
    func score() -> Int{
        switch self {
        case .goodJoker, .badJoker:
            //A joker counts for nothing, lower than a two
            return 0
        case .ace:
            return 14
        case .two:
            return 2
        case .three:
            return 3
        case .four:
            return 4
        case .five:
            return 5
        case .six:
            return 6
        case .seven:
            return 7
        case .eight:
            return 8
        case .nine:
            return 9
        case .ten:
            return 10
        case .jack:
            return 11
        case .queen:
            return 12
        case .king:
            return 13
        }
    }
    
    static func unflatten(flattened: String) -> Rank? {
        switch flattened.lowercased() {
        case "a": return .ace
        case "2": return .two
        case "3": return .three
        case "4": return .four
        case "5": return .five
        case "6": return .six
        case "7": return .seven
        case "8": return .eight
        case "9": return .nine
        case "t": return .ten
        case "j": return .jack
        case "q": return .queen
        case "k": return .king
        default: return nil
        }
    }
}

struct PlayingCard : Equatable{
    let suit : Suit
    let rank : Rank
    
    ///The jokers are only in the pack for the Looky Looky rules
    static let goodJoker = PlayingCard(suit: .joker, rank: .goodJoker)
    static let badJoker = PlayingCard(suit: .joker, rank: .badJoker)

    ///The 52 cards of a standard pack, no jokers
    static let standardPack : [PlayingCard] = Suit.standard.flatMap{ suit in
        Rank.standard.map{ rank in PlayingCard(suit: suit, rank: rank)}
    }

    var isJoker : Bool {
        return rank.isJoker
    }

    ///The good joker is wild, it can stand in for any card of the standard pack that is not already in the hand.
    ///Returns the hand with the good joker replaced by the card that gives the best score,
    ///a hand without the good joker is returned unchanged.
    static func playGoodJoker(hand : [PlayingCard], score : ([PlayingCard]) -> BragHandScore) -> [PlayingCard] {
        guard let index = hand.firstIndex(of: goodJoker) else {
            return hand
        }
        var bestHand = hand
        var bestScore : BragHandScore? = nil
        for card in standardPack where !hand.contains(card) {
            var candidate = hand
            candidate[index] = card
            let candidateScore = score(candidate)
            if bestScore == nil || candidateScore > bestScore! {
                bestScore = candidateScore
                bestHand = candidate
            }
        }
        return bestHand
    }

    func display() -> String {
        return "\(suit.display())\(rank.display())"
    }
    
    var isRed : Bool {
        return suit == .diamonds || suit == .hearts
    }
    
    static func ==(lhs: PlayingCard, rhs: PlayingCard) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }

    ///Jokers are GJ (good) and BJ (bad)
    static func unflatten(flattened : String) -> PlayingCard? {
        switch flattened.lowercased() {
        case "gj": return goodJoker
        case "bj": return badJoker
        default: break
        }
        guard flattened.count == 2,
              let rank = Rank.unflatten(flattened: String(flattened[flattened.startIndex])),
              let suit = Suit.unflatten(flattened: String(flattened[flattened.index(before: flattened.endIndex)]))
        else {
            return nil
        }
        return PlayingCard(suit: suit, rank: rank)
    }
}

