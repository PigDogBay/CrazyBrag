//
//  Hand.swift
//  CardGames
//
//  Created by Mark Bailey on 09/09/2022.
//

import Foundation

class PlayerHand {
    var hand : [PlayingCard]
    
    var score : BragHandScore {
        let resolver = HandResolver(hand: hand)
        return resolver.createScore()
    }
    
    init(hand : [PlayingCard]){
        self.hand = hand
    }
    
    convenience init(){
        self.init(hand: [PlayingCard]())
    }
    
    ///Turn all cards up
    func show(){}
    func hide(){}

    func receive(card : PlayingCard){
        hand.append(card)
    }
    
    func display() -> String {
        return hand.map{$0.display()}.joined(separator: "_")
    }
    
    func stash() -> [PlayingCard] {
        let stash = hand
        hand.removeAll()
        return stash
    }
    
    func replace(cardInHand : PlayingCard,  with : PlayingCard) {
        if let index = hand.firstIndex(of: cardInHand) {
            hand.remove(at: index)
            hand.insert(with, at: index)
        }
    }
    
    func play(turn : Turn, middle : PlayerHand){
        switch turn {
        case .swap(hand: let handCard, middle: let middleCard):
            replace(cardInHand: handCard, with: middleCard)
            middle.replace(cardInHand: middleCard, with: handCard)
        case .all(downIndex: let index):
            let tmp = self.hand
            self.hand = middle.hand
            middle.hand = tmp
            //First card is down
            let down = middle.hand.remove(at: index)
            middle.hand.insert(down, at: 0)
        }
    }
    
    func indexOf(card : PlayingCard) -> Int{
        return hand.firstIndex(of: card) ?? -1
    }
}
