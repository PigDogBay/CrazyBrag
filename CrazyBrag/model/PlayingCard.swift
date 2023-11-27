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
}

