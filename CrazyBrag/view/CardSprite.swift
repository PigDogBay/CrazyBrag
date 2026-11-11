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
        switch self.rank {
        case .goodJoker:
            return "JokerGood"
        case .badJoker:
            return "JokerBad"
        default:
            return self.rank.display() + suitLetter
        }
    }
    
    //Get the image asset's name for the marked back of the card
    var markedBackImageName : String {
        return "Back" + imageName
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
        case .joker:
            return ""
        }
    }
    
    var nodeName : String {
        return"card \(self.imageName)"
    }
}

class CardSpriteNode : SKSpriteNode {
    let playingCard : PlayingCard
    let frontTexture : SKTexture
    static let plainBackImageName = "CardBack"
    ///With the marked deck each card has its own back, marked so that a sharp eyed player can read it,
    ///see tools/cards/cards.py for the key to the marks. Otherwise all the cards share the plain back.
    private(set) var backTexture : SKTexture

    private static func createBackTexture(card : PlayingCard) -> SKTexture {
        let backImageName = Settings().markedDeck ? card.markedBackImageName : CardSpriteNode.plainBackImageName
        return SKTexture(imageNamed: backImageName)
    }

    init(card : PlayingCard, cardSize : CGSize){
        self.playingCard = card
        self.frontTexture = SKTexture(imageNamed: playingCard.imageName)
        self.backTexture = CardSpriteNode.createBackTexture(card: card)
        super.init(texture: backTexture, color: .white, size: cardSize)
        self.name = card.nodeName
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///The deck setting has changed, use the new back
    func reloadBack(){
        let isFaceDown = texture === backTexture
        backTexture = CardSpriteNode.createBackTexture(card: playingCard)
        if isFaceDown {
            texture = backTexture
        }
    }

    func faceDown(){
        self.texture = backTexture
    }
    func faceUp(){
        self.texture = frontTexture
    }
}
