//
//  Deck.swift
//  CardGames
//
//  Created by Mark Bailey on 09/09/2022.
//

import Foundation

class Deck {
    var deck = [PlayingCard]()
    
    func createDeck(){
        deck.removeAll()
        Suit.allCases.forEach{ suit in
            Rank.allCases.forEach {rank in
                deck.append(PlayingCard(suit: suit, rank: rank))
            }
        }
    }
    
    var count : Int {
        deck.count
    }
    
    func printDeck(){
        deck.forEach {
            print($0.display())
        }
    }
    
    func shuffle(){
        deck.shuffle()
        deck.shuffle()
    }
    
    func deal(dealUp : Bool = false) -> PlayingCard {
        var card = deck.removeFirst()
        card.isDown = !dealUp
        return card
    }
    
    func receive(cards : [PlayingCard]) throws {
        try cards.forEach{
            if deck.contains($0) {
                throw CardErrors.CardAlreadyInThePack(card: $0)
            }
            var card = $0
            //Unbox cards
            card.isDown = true
            deck.append(card)
        }
    }
}
