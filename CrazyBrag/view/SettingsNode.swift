//
//  SettingsNode.swift
//  CrazyBrag
//
//  The settings panel on the start screen: choose the game mode and the deck.
//  The choices are saved straightaway (they are the same settings as in the iOS Settings app).
//

import SpriteKit

class SettingsNode : SKShapeNode {
    enum Option : String {
        case deadwood, lookyLooky = "looky looky", plainDeck = "plain", markedDeck = "marked"
    }

    private let layout : InformationLayout
    private let settings = Settings()
    private var optionNodes = [Option : SKShapeNode]()
    ///Called when the deck is changed, so that cards already on screen can change their backs
    var onDeckChanged : (()->Void)? = nil

    override init(){
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        self.layout = InformationLayout(isPhone: isPhone)
        super.init()
        isUserInteractionEnabled = true
        fillColor = UIColor(named: "RulesBG")!
        strokeColor = .clear
        path = UIBezierPath(roundedRect: layout.frame, cornerRadius: 10).cgPath
        addLabel(name: "title", text: "GAME SETTINGS", fontNamed: "QuentinCaps", fontSize: layout.titleFontSize, position: layout.titlePosition)
        addLabel(name: "close", text: "X", fontNamed: "AmericanTypewriter", fontSize: layout.closeFontSize, position: layout.closePosition)
        //Rows are placed in proportion to the panel, which is 400 high on the iPhone
        let unit = layout.frame.height / 400.0
        addRow(title: "GAME", y: layout.frame.minY + 262.0 * unit, unit: unit,
               left: .deadwood, leftText: "DEADWOOD", right: .lookyLooky, rightText: "LOOKY LOOKY")
        addRow(title: "DECK", y: layout.frame.minY + 137.0 * unit, unit: unit,
               left: .plainDeck, leftText: "PLAIN", right: .markedDeck, rightText: "MARKED")
        refresh()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLabel(name : String, text : String, fontNamed : String, fontSize : Double, position : CGPoint){
        let label = SKLabelNode(fontNamed: fontNamed)
        label.name = name
        label.text = text
        label.fontColor = .white
        label.fontSize = fontSize
        label.position = position
        label.zPosition = 1
        addChild(label)
    }

    ///A heading with the two choices side by side beneath it
    private func addRow(title : String, y : CGFloat, unit : CGFloat, left : Option, leftText : String, right : Option, rightText : String){
        addLabel(name: "heading", text: title, fontNamed: "AmericanTypewriter", fontSize: layout.bodyFontSize,
                 position: CGPoint(x: layout.frame.midX, y: y))
        let size = CGSize(width: 210.0 * unit, height: 54.0 * unit)
        let buttonY = y - 48.0 * unit
        addOption(left, text: leftText, size: size, fontSize: 24.0 * unit,
                  position: CGPoint(x: layout.frame.midX - 115.0 * unit, y: buttonY))
        addOption(right, text: rightText, size: size, fontSize: 24.0 * unit,
                  position: CGPoint(x: layout.frame.midX + 115.0 * unit, y: buttonY))
    }

    private func addOption(_ option : Option, text : String, size : CGSize, fontSize : CGFloat, position : CGPoint){
        let button = SKShapeNode(rectOf: size, cornerRadius: size.height / 4.0)
        button.name = option.rawValue
        button.strokeColor = .white
        button.lineWidth = 2.0
        button.position = position
        button.zPosition = 1
        let label = SKLabelNode(fontNamed: "QuentinCaps")
        label.name = option.rawValue
        label.text = text
        label.fontSize = fontSize
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        button.addChild(label)
        addChild(button)
        optionNodes[option] = button
    }

    private func isSelected(_ option : Option) -> Bool {
        switch option {
        case .deadwood: return !settings.lookyLooky
        case .lookyLooky: return settings.lookyLooky
        case .plainDeck: return !settings.markedDeck
        case .markedDeck: return settings.markedDeck
        }
    }

    ///Highlight the options that are currently chosen
    private func refresh(){
        for (option, button) in optionNodes {
            let selected = isSelected(option)
            button.fillColor = UIColor(white: 1.0, alpha: selected ? 0.9 : 0.1)
            (button.children.first as? SKLabelNode)?.fontColor = selected ? .black : .white
        }
    }

    func select(_ option : Option){
        switch option {
        case .deadwood:
            settings.lookyLooky = false
        case .lookyLooky:
            settings.lookyLooky = true
        case .plainDeck, .markedDeck:
            let marked = option == .markedDeck
            if marked != settings.markedDeck {
                settings.markedDeck = marked
                onDeckChanged?()
            }
        }
        refresh()
    }

    func close(){
        removeFromParent()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let name = atPoint(touch.location(in: self)).name else {
            return
        }
        if name == "close" {
            close()
        } else if let option = Option(rawValue: name) {
            select(option)
        }
    }
}
