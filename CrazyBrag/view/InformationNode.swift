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
    ///The rules being read, nil while the player is choosing between them
    private var pages : [String]? = nil
    var index = 1
    private var optionNodes = [SKNode]()
    private var pageControlNodes = [SKNode]()

    ///The standard game
    static let deadwoodPages = [
        "Each player has 3 lives and takes turns\nto swap cards with the middle 3 cards.\n\nAt the end of the round the player with\nthe lowest scoring hand loses a life.",
        "If a player loses all their lives,\nthey are out of the game.\n\nPlay continues until there\nis only one player left.",
        "On your turn you must swap\n1 or 3 cards with the middle\n\nTouch a card in your hand to select it\nthen touch a middle card to swap",
        "To swap all three cards\nTouch all 3 cards in your hand\n\nThe first card selected will be\nplaced face down in the middle",
        "HANDS: HIGH\nThe highest card in your hand\nA♣️J♦️2❤️ - This is Ace high\n\n5♦️3❤️2♣️ is the lowest possible hand",
        "PAIR\nTwo cards with the same rank\nJ♦️J♠️9❤️ - Pair of Jacks\n\nAces are high, 2's lowest",
        "FLUSH\nAll cards are the same suit\nK❤️9❤️8❤️ - King Flush\n\nIf two king flushes are losing,\nthe next card will be compared.",
        "RUN\nSequential Ranks\n7♦️8♠️9♣️ - Seven, eight, nine\n\nA♠️2♣️3♦️ is the highest run\nThen QKA, JQK, TJQ, 9TJ...234",
        "TROTTER\nRun and all the same suit\nJ♦️Q♦️K♦️ - Jack Queen King Trotter\n\nCards can be in any order",
        "PRIAL\nAll cards are the same rank\nQ♠️Q❤️Q♦️ - Prial of Queens\n\n333's are the highest prial\nThen AAA, KKK...222\nAll lesser hands will lose a life!",
    ]

    ///The extra rules of the Looky Looky game
    static let lookyLookyPages = [
        "Looky Looky is Deadwood\nwith a few house rules.\n\nEverything in the Deadwood rules\nstill applies, so read those first.",
        "EXTRA LIFE\nYour first winning prial earns you\nan extra life and nobody loses a life.\n\nThe grey heart is the life to be won.\nAfter that your prials work as usual.",
        "BULLET PROOF\nWhen a prial wins the round,\na player holding a trotter\nor a lesser prial is safe\nand keeps their life.",
        "JOKERS\nWild Bill is wild, he plays as any\ncard that is not already in your hand.\n\nCalamity Jane is a dud,\nshe counts for nothing.",
        "DEUCES ARE WILD\nA 2 can be any suit,\nbut it is always a 2.\n\n2♦️K♠️9♠️ - King Flush\n2❤️3♠️4♠️ - 2-3-4 Trotter",
        "ACTIONS\nBefore making your move you may take\nup to 2 of the 3 actions,\nusing the buttons next to your hand.\n\nEach action only once a turn.",
        "LOOKY LOOKY\nPeek at the face down card\nin the middle.\n\nOnly you get to see it.",
        "STASH HAND\nThrow in all 3 of your cards\nand get 3 new ones.\n\nCHANGE A CARD\nPick a middle card to be\nreplaced with a new one.",
    ]

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
        addOptions()
        showOptions()
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
            bodyTextNode.run(fadeOut, withKey: "show")
            return
        }

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let setText = SKAction.run { [weak self] in self?.bodyTextNode.attributedText = NSAttributedString(string: message, attributes: self?.attributes)}
        let sequence = SKAction.sequence([fadeOut,setText,fadeIn])
        bodyTextNode.run(sequence, withKey: "show")
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
        pageControlNodes = [prevNode, nextNode, pageNumberNode]
    }

    ///The first page: choose which rules to read
    func addOptions(){
        optionNodes = [
            createOption(name: "deadwood", text: "DEADWOOD", position: layout.option1Position),
            createOption(name: "looky looky", text: "LOOKY LOOKY", position: layout.option2Position),
        ]
        optionNodes.forEach{addChild($0)}
    }

    private func createOption(name : String, text : String, position : CGPoint) -> SKNode {
        let size = layout.optionSize
        let button = SKShapeNode(rectOf: size, cornerRadius: size.height / 4.0)
        button.name = name
        button.fillColor = UIColor(white: 1.0, alpha: 0.15)
        button.strokeColor = .white
        button.lineWidth = 2.0
        button.position = position
        button.zPosition = 1003
        let label = SKLabelNode(fontNamed: "QuentinCaps")
        label.name = name
        label.text = text
        label.fontColor = .white
        label.fontSize = layout.optionFontSize
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        button.addChild(label)
        return button
    }

    ///Back to choosing the rules
    func showOptions(){
        pages = nil
        index = 1
        (childNode(withName: "title") as? SKLabelNode)?.text = "RULES"
        optionNodes.forEach{$0.isHidden = false}
        pageControlNodes.forEach{$0.isHidden = true}
        show(message: "")
    }

    ///The options go and the pages of the chosen rules can be stepped through
    func select(pages : [String], title : String){
        self.pages = pages
        (childNode(withName: "title") as? SKLabelNode)?.text = title
        index = 1
        optionNodes.forEach{$0.isHidden = true}
        pageControlNodes.forEach{$0.isHidden = false}
        updatePage()
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
    
    func selectDeadwood(){
        select(pages: InformationNode.deadwoodPages, title: "DEADWOOD")
    }

    func selectLookyLooky(){
        select(pages: InformationNode.lookyLookyPages, title: "LOOKY LOOKY")
    }

    func updatePage(){
        guard let pages = pages else {
            return
        }
        show(message: pages[index - 1])
        pageNumberNode.text = "\(index) of \(pages.count)"
    }
    
    ///Going back from the first page returns to the choice of rules
    func previous(){
        guard pages != nil else {
            return
        }
        if index == 1 {
            showOptions()
            return
        }
        index = index - 1
        updatePage()
    }

    func next(){
        guard let pages = pages, index < pages.count else {
            return
        }
        index = index + 1
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
            } else if pages == nil && node.name == "deadwood" {
                selectDeadwood()
            } else if pages == nil && node.name == "looky looky" {
                selectLookyLooky()
            }
        }
    }

}
