//
//  InformationNode.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 21/12/2023.
//

import SpriteKit

class InformationNode : SKShapeNode {
    let attributes: [NSAttributedString.Key : Any]
    let bodyTextNode = SKLabelNode(fontNamed: "QuentinCaps")

    override init(){
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 10.0
        attributes = [
            .foregroundColor : SKColor.white,
            .backgroundColor: UIColor.clear,
            //Other fonts: Baskerville-SemiBold, ChalkboardSE-Regular
            .font: UIFont(name: "AmericanTypewriter", size: 18.0)!,
            .paragraphStyle: paragraph
        ]
        super.init()

        fillColor = UIColor(named: "RulesBG")!
        strokeColor = .clear
        //Create path so that the rect is centered
        path = UIBezierPath(roundedRect: CGRect(x: 216, y: 15, width: 500.0, height: 400.0), cornerRadius: 10).cgPath
        addTitle()
        addBodyTextNode()
        show(message: "Mary had a little lamb\nits fleece was white as snow\nevery where where mary went\nthat lamb was surely to go")
    }
    
    func addTitle(){
        let label = SKLabelNode(fontNamed: "QuentinCaps")
        label.name = "title"
        label.text = "RULES"
        label.fontColor = SKColor.white
        label.fontSize = 32.0
        label.position = CGPoint(x: self.frame.midX, y: self.frame.height * 0.9)
        label.zPosition = 1001
        addChild(label)
    }
    
    func addBodyTextNode() {
        bodyTextNode.name = "body text"
        bodyTextNode.numberOfLines = 4
        bodyTextNode.zPosition = 1002
        bodyTextNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        addChild(bodyTextNode)

    }
    ///Fades out the previous message and then fades in the new
    func show(message : String) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        //NOTA BENE: an empty string will blow up attributedText with NSMutableRLEArray out of bounds exception
        //Trap it here and just fade out the existing text
        if (message.isEmpty){
            bodyTextNode.run(fadeOut)
            return
        }

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let setText = SKAction.run { [weak self] in self?.bodyTextNode.attributedText = NSAttributedString(string: message, attributes: self?.attributes)}
        let sequence = SKAction.sequence([fadeOut,setText,fadeIn])
        bodyTextNode.run(sequence)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
