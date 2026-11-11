//
//  Deck.swift
//  CardGames
//
//  Created by Mark Bailey on 09/09/2022.
//

import Foundation

class Deck {
    var deck = [PlayingCard]()
    ///Looky Looky rules: the good and bad jokers are added to the pack
    var hasJokers = false
    
    ///The number of cards in a full pack, which depends on the rule set
    var max : Int {
        return hasJokers ? 54 : 52
    }
    
    func createDeck(){
        deck.removeAll()
        deck.append(contentsOf: PlayingCard.standardPack)
        if hasJokers {
            deck.append(PlayingCard.goodJoker)
            deck.append(PlayingCard.badJoker)
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
        return deck.removeFirst()
    }
    
    func receive(cards : [PlayingCard]) throws {
        try cards.forEach{
            if deck.contains($0) {
                throw CardErrors.CardAlreadyInThePack(card: $0)
            }
            deck.append($0)
        }
    }
    
    ///Reduce the deck size to the numberOfCards
    func cut(numberOfCards : Int) {
        let cardsToRemove = count - numberOfCards
        if cardsToRemove>0 {
            for _ in 1...cardsToRemove {
                deck.removeLast()
            }
        }
    }
    
    func remove(card : PlayingCard){
        deck.removeAll(where: {$0 == card})
    }
}
