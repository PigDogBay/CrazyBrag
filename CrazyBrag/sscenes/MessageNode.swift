//
//  MessageNode.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 06/12/2023.
//

import Foundation
import SpriteKit

class MessageNode : SKLabelNode {
    let attributes: [NSAttributedString.Key : Any]

    override init(){
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        attributes = [
            .foregroundColor : SKColor.black,
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: "QuentinCaps", size: 28.0)!,
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
    
    func show(message : String) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)

        let setText = SKAction.run { [weak self] in self?.attributedText = NSAttributedString(string: message, attributes: self?.attributes)}
        let sequence = SKAction.sequence([fadeOut,setText,fadeIn])
        run(sequence)
    }
}
