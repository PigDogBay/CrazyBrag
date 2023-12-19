//
//  PlayingCard.swift
//  CardGames
//
//  Created by Mark Bailey on 09/09/2022.
//

import Foundation

enum Suit : Int, CaseIterable {
    case clubs, diamonds, hearts, spades
    
    func display() -> String  {
        switch self {
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
    
    func display() -> String  {
        switch self {
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
    
    func display() -> String {
        return "\(suit.display())\(rank.display())"
    }
    
    var isRed : Bool {
        return suit == .diamonds || suit == .hearts
    }
    
    static func ==(lhs: PlayingCard, rhs: PlayingCard) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }

    static func unflatten(flattened : String) -> PlayingCard? {
        guard flattened.count == 2,
              let rank = Rank.unflatten(flattened: String(flattened[flattened.startIndex])),
              let suit = Suit.unflatten(flattened: String(flattened[flattened.index(before: flattened.endIndex)]))
        else {
            return nil
        }
        return PlayingCard(suit: suit, rank: rank)
    }
}

