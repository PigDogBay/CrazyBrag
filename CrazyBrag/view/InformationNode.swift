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
    let pageNumberNode = SKLabelNode(fontNamed: "AmericanTypewriter")
    var index = 1
    let maxIndex = 10
    
    let page1 = "Each player has 3 lives and takes turns\nto swap cards with the middle 3 cards.\n\nAt the end of the round the player with\nthe lowest scoring hand loses a life."
    let page2 = "If a player loses all their lives,\nthey are out of the game.\n\nPlay continues until there is only one player left."
    let page3 = "On your turn you must swap\n1 or 3 cards with the middle\n\nTouch a card in your hand to select it\nThen touch a middle card to swap"
    let page4 = "To swap all three cards\nTouch all 3 cards in your hand\n\nThe first card selected will be\nplaced face down in the middle"
    let page5 = "HANDS: HIGH\nThe highest card in your hand\nA♣️J♦️2❤️ - This is Ace high\n5♦️3❤️2♣️ is the lowest possible hand"
    let page6 = "PAIR\nTwo cards with the same rank\nJ♦️J♠️9❤️ - Pair of Jacks\nAces are high, 2's lowest"
    let page7 = "FLUSH\nAll cards are the same suit\nK❤️9❤️8❤️ - King Flush\nIf two king flushes are losing,\nthe next card will be compared."
    let page8 = "RUN\nSequential Ranks\n7♦️8♠️9♣️ - Seven, eight, nine\nA♠️2♣️3♦️ is the highest run\nThen QKA, JQK, TJQ, 9TJ...234"
    let page9 = "TROTTER\nRun and all the same suit\nJ♦️Q♦️K♦️ - Jack Queen King Trotter"
    let page10 = "PRIAL\nAll cards are the same rank\nQ♠️Q❤️Q♦️ - Prial of Queens\n333's are the highest prial\nThen AAA, KKK...222\nAll losing hands will lose a life!"

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

        isUserInteractionEnabled = true
        fillColor = UIColor(named: "RulesBG")!
        strokeColor = .clear
        //Create path so that the rect is centered
        path = UIBezierPath(roundedRect: CGRect(x: 216, y: 15, width: 500.0, height: 400.0), cornerRadius: 10).cgPath
        addTitle()
        addBodyTextNode()
        addPageControl()
        addCloseButton()
        updatePage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        bodyTextNode.fontSize = 18.0
        bodyTextNode.numberOfLines = 8
        bodyTextNode.zPosition = 1002
        bodyTextNode.verticalAlignmentMode = .center
        bodyTextNode.position = CGPoint(x: self.frame.midX, y: 225)
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
    
    func addPageControl(){
        let prevNode = SKLabelNode(fontNamed: "AmericanTypewriter")
        prevNode.fontSize = 32.0
        prevNode.name = "previous"
        prevNode.text = "<"
        prevNode.color = .white
        prevNode.zPosition = 1003
        prevNode.position = CGPoint(x: 406.0, y: 40.0)

        let nextNode = SKLabelNode(fontNamed: "AmericanTypewriter")
        nextNode.fontSize = 32.0
        nextNode.name = "next"
        nextNode.text = ">"
        nextNode.color = .white
        nextNode.zPosition = 1003
        nextNode.position = CGPoint(x: 526, y: 40.0)

        pageNumberNode.fontSize = 18.0
        pageNumberNode.name = "page number"
        pageNumberNode.text = "1 of 4"
        pageNumberNode.color = .white
        pageNumberNode.zPosition = 1003
        pageNumberNode.position = CGPoint(x: 466, y: 45.0)
        
        addChild(prevNode)
        addChild(nextNode)
        addChild(pageNumberNode)
    }
    
    func addCloseButton(){
        let label = SKLabelNode(fontNamed: "AmericanTypewriter")
        label.fontSize = 24.0
        label.name = "close"
        label.text = "X"
        label.color = .white
        label.zPosition = 1003
        label.position = CGPoint(x: 698, y: 388)
        addChild(label)
    }
    
    func updatePage(){
        switch(index) {
        case 2:
            show(message: page2)
        case 3:
            show(message: page3)
        case 4:
            show(message: page4)
        case 5:
            show(message: page5)
        case 6:
            show(message: page6)
        case 7:
            show(message: page7)
        case 8:
            show(message: page8)
        case 9:
            show(message: page9)
        case 10:
            show(message: page10)
        default:
            show(message: page1)
        }
        pageNumberNode.text = "\(index) of \(maxIndex)"
    }
    
    func previous(){
        index = index - 1
        if index == 0 {
            index = 1
        }
        updatePage()
    }

    func next(){
        index = index + 1
        if index > maxIndex {
            index = maxIndex
        }
        updatePage()
    }
    
    func close(){
        removeFromParent()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if node.name == "previous" {
                previous()
            } else if node.name == "next" {
                next()
            } else if node.name == "close"{
                close()
            }
        }
    }

}
