//
//  CardSprite.swift
//  Cards
//
//  Created by Mark Bailey on 21/06/2023.
//

import Foundation
import SpriteKit

class CardSpriteNode : SKSpriteNode {
    
    init(imageNamed image: String, cardSize : CGSize){
        let texture = SKTexture(imageNamed: image)
        super.init(texture: texture, color: .white, size: cardSize)
        self.name = "card \(image)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func turnCard(){
        let texture = SKTexture(imageNamed: "CardBack")
        self.texture = texture
    }
}
