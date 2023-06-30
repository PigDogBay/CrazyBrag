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
    static let backImageName = "CardBack"
    let playingCard : PlayingCard
    let frontTexture : SKTexture
    
    static let backTexture = SKTexture(imageNamed: backImageName)
    
    init(card : PlayingCard, cardSize : CGSize){
        self.playingCard = card
        self.frontTexture = SKTexture(imageNamed: playingCard.imageName)

        let texture = CardSpriteNode.backTexture
        super.init(texture: texture, color: .white, size: cardSize)
        self.name = "card \(card.imageName)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func turnCardDown(){
        self.texture = CardSpriteNode.backTexture
    }
    func turnCardUp(){
        self.texture = frontTexture
    }
}
