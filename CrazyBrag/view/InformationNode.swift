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
    let layout : InformationLayout
    var index = 1
    let maxIndex = 10
    
    let page1 = "Each player has 3 lives and takes turns\nto swap cards with the middle 3 cards.\n\nAt the end of the round the player with\nthe lowest scoring hand loses a life."
    let page2 = "If a player loses all their lives,\nthey are out of the game.\n\nPlay continues until there\nis only one player left."
    let page3 = "On your turn you must swap\n1 or 3 cards with the middle\n\nTouch a card in your hand to select it\nthen touch a middle card to swap"
    let page4 = "To swap all three cards\nTouch all 3 cards in your hand\n\nThe first card selected will be\nplaced face down in the middle"
    let page5 = "HANDS: HIGH\nThe highest card in your hand\nA♣️J♦️2❤️ - This is Ace high\n\n5♦️3❤️2♣️ is the lowest possible hand"
    let page6 = "PAIR\nTwo cards with the same rank\nJ♦️J♠️9❤️ - Pair of Jacks\n\nAces are high, 2's lowest"
    let page7 = "FLUSH\nAll cards are the same suit\nK❤️9❤️8❤️ - King Flush\n\nIf two king flushes are losing,\nthe next card will be compared."
    let page8 = "RUN\nSequential Ranks\n7♦️8♠️9♣️ - Seven, eight, nine\n\nA♠️2♣️3♦️ is the highest run\nThen QKA, JQK, TJQ, 9TJ...234"
    let page9 = "TROTTER\nRun and all the same suit\nJ♦️Q♦️K♦️ - Jack Queen King Trotter\n\nCards can be in any order"
    let page10 = "PRIAL\nAll cards are the same rank\nQ♠️Q❤️Q♦️ - Prial of Queens\n\n333's are the highest prial\nThen AAA, KKK...222\nAll lesser hands will lose a life!"

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
        prevNode.fontSize = layout.controlFontSize
        prevNode.name = "previous"
        prevNode.text = "<"
        prevNode.color = .white
        prevNode.zPosition = 1003
        prevNode.position = layout.previousPosition

        let nextNode = SKLabelNode(fontNamed: "AmericanTypewriter")
        nextNode.fontSize = layout.controlFontSize
        nextNode.name = "next"
        nextNode.text = ">"
        nextNode.color = .white
        nextNode.zPosition = 1003
        nextNode.position = layout.nextPosition

        pageNumberNode.fontSize = layout.pageFontSize
        pageNumberNode.name = "page number"
        pageNumberNode.text = "1 of 4"
        pageNumberNode.color = .white
        pageNumberNode.zPosition = 1003
        pageNumberNode.position = layout.pagePosition
        
        addChild(prevNode)
        addChild(nextNode)
        addChild(pageNumberNode)
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
