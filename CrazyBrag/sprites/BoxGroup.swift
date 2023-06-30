//
//  BoxGroup.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 30/06/2023.
//

import Foundation
import SpriteKit

class BoxGroup{
    let layout : BoxLayout
    var cards : [CardSpriteNode] = []
    
    init(layout : BoxLayout){
        self.layout = layout
    }
    
    func addCard(scene : SKScene, card : PlayingCard){
        let cardSprite = CardSpriteNode(card: card, cardSize: layout.cardSize)
        cardSprite.name = card.imageName
        switch cards.count {
        case 1:
            cardSprite.position = layout.position2
            cardSprite.zPosition = CGFloat(integerLiteral: 9)
        case 2:
            cardSprite.position = layout.position3
            cardSprite.zPosition = CGFloat(integerLiteral: 10)
        default:
            cardSprite.position = layout.position1
            cardSprite.zPosition = CGFloat(integerLiteral: 8)
        }
        cards.append(cardSprite)
        scene.addChild(cardSprite)
    }
    
}
