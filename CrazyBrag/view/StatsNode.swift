//
//  StatsNode.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 20/02/2024.
//


import SpriteKit

class StatsNode : SKShapeNode {
    let attributes: [NSAttributedString.Key : Any]
    let bodyTextNode = SKLabelNode(fontNamed: "QuentinCaps")
    let pageNumberNode = SKLabelNode(fontNamed: "AmericanTypewriter")
    let layout : InformationLayout

    override init(){
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        self.layout = InformationLayout(isPhone: isPhone)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = layout.lineSpacing
        attributes = [
            .foregroundColor : SKColor.white,
            .backgroundColor: UIColor.clear,
            //Other fonts: Baskerville-SemiBold, ChalkboardSE-Regular
            .font: UIFont(name: "AmericanTypewriter", size: layout.bodyFontSize)!,
            .paragraphStyle: paragraph
        ]
        super.init()

        isUserInteractionEnabled = true
        fillColor = UIColor(named: "RulesBG")!
        strokeColor = .clear
        //Create path so that the rect is centered
        path = UIBezierPath(roundedRect: layout.frame, cornerRadius: 10).cgPath
        addTitle()
        addBodyTextNode()
        addCloseButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(message : String) {
        bodyTextNode.attributedText = NSAttributedString(string: message, attributes: attributes)
    }

    func addTitle(){
        let label = SKLabelNode(fontNamed: "QuentinCaps")
        label.name = "title"
        label.text = "STATS"
        label.fontColor = SKColor.white
        label.fontSize = layout.titleFontSize
        label.position = layout.titlePosition
        label.zPosition = 1001
        addChild(label)
    }
    
    func addBodyTextNode() {
        bodyTextNode.name = "body text"
        bodyTextNode.numberOfLines = 8
        bodyTextNode.zPosition = 1002
        bodyTextNode.verticalAlignmentMode = .center
        bodyTextNode.position = layout.bodyPosition
        addChild(bodyTextNode)
    }
    
    func addCloseButton(){
        let label = SKLabelNode(fontNamed: "AmericanTypewriter")
        label.fontSize = layout.closeFontSize
        label.name = "close"
        label.text = "X"
        label.color = .white
        label.zPosition = 1003
        label.position = layout.closePosition
        addChild(label)
    }
    
    func close(){
        removeFromParent()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if node.name == "close"{
                close()
            }
        }
    }

}
