//
//  GameVariation.swift
//  CardGames
//
//  Created by Mark Bailey on 07/10/2022.
//

import Foundation

protocol GameVariation : AnyObject {
    func arrangeMiddle(middle : PlayerHand, turn : Turn)
    func isMiddleCardFaceUp(dealIndex : Int) -> Bool
}

class VariationAllUp : GameVariation {
    func arrangeMiddle(middle : PlayerHand, turn : Turn) {
        //Easy for all up, just make sure they are all shown
        middle.show()
    }
    func isMiddleCardFaceUp(dealIndex : Int) -> Bool {
        //all cards up
        return true
    }
}


class VariationOneDown : GameVariation {
    
    func arrangeMiddle(middle : PlayerHand, turn : Turn) {
        switch turn {
        case .swap(let handCard, let middleCard):
            //find the hand card in the middle
            if let index = middle.hand.firstIndex(of: handCard) {
                //set the face up/down state to the previous middle card
                middle.hand[index].isDown = middleCard.isDown
            }
        case .all:
            //For now select last card as down, AI will have to do some work here
            middle.show()
            middle.hand[2].isDown = true
        }
    }
    
    func isMiddleCardFaceUp(dealIndex : Int) -> Bool {
        return dealIndex != 3
    }
}
