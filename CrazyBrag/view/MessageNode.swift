//
//  MessageNode.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 06/12/2023.
//

import Foundation
import SpriteKit

class MessageNode : SKLabelNode {
    ///Uses attributedText so that multi-line text can be center justified
    let attributes: [NSAttributedString.Key : Any]

    init(fontSize : CGFloat){
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        attributes = [
            .foregroundColor : SKColor.black,
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: "QuentinCaps", size: fontSize)!,
            .paragraphStyle: paragraph
        ]

        super.init()

        name = "messages"
        numberOfLines = 4
        zPosition = Layer.messages.rawValue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    ///Fades out the previous message and then fades in the new
    func show(message : String) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        //NOTA BENE: an empty string will blow up attributedText with NSMutableRLEArray out of bounds exception
        //Trap it here and just fade out the existing text
        if (message.isEmpty){
            run(fadeOut)
            return
        }

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let setText = SKAction.run { [weak self] in self?.attributedText = NSAttributedString(string: message, attributes: self?.attributes)}
        let sequence = SKAction.sequence([fadeOut,setText,fadeIn])
        run(sequence)
    }
}
