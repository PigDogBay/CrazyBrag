//
//  CardSprite.swift
//  Cards
//
//  Created by Mark Bailey on 21/06/2023.
//

import Foundation
import SpriteKit

extension PlayingCard {
    //Get the image asset's name for the card
    var imageName : String {
        return self.rank.display() + suitLetter
    }
    
    var suitLetter : String{
        switch self.suit {
        case .clubs:
            return "C"
        case .diamonds:
            return "D"
        case .hearts:
            return "H"
        case .spades:
            return "S"
        }
    }
}

class CardSpriteNode : SKSpriteNode {
    
    let playingCard : PlayingCard
    
    init(imageNamed image: String, cardSize : CGSize){
        self.playingCard = PlayingCard(suit: .spades, rank: .ace)
        let texture = SKTexture(imageNamed: image)
        super.init(texture: texture, color: .white, size: cardSize)
        self.name = "card \(image)"
    }

    init(card : PlayingCard, cardSize : CGSize){
        self.playingCard = card
        let texture = SKTexture(imageNamed: card.imageName)
        super.init(texture: texture, color: .white, size: cardSize)
        self.name = "card \(card.imageName)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func turnCard(){
        let texture = SKTexture(imageNamed: "CardBack")
        self.texture = texture
    }
}
