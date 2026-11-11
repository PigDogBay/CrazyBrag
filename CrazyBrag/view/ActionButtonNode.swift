//
//  ActionButtonNode.swift
//  CrazyBrag
//
//  Looky Looky rules: a round icon button for one of the actions a player can take before their move
//

import SpriteKit

class ActionButtonNode : SKSpriteNode {
    private let onPressed : ()->Void
    private var state = ActionButtonState.disabled
    private var isButtonPressed = false

    init(imageNamed : String, size : CGFloat, onPressed : @escaping ()->Void){
        self.onPressed = onPressed
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: .clear, size: CGSize(width: size, height: size))
        isUserInteractionEnabled = true
        show(state: .disabled)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(state : ActionButtonState){
        self.state = state
        removeAllActions()
        setScale(1.0)
        switch state {
        case .disabled:
            alpha = 0.3
        case .enabled:
            alpha = 1.0
        case .selected:
            alpha = 1.0
            //Pulse while waiting for the player to pick a card
            let bigger = SKAction.scale(to: 1.2, duration: 0.4)
            let smaller = SKAction.scale(to: 1.0, duration: 0.4)
            run(SKAction.repeatForever(SKAction.sequence([bigger, smaller])))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state != .disabled {
            isButtonPressed = true
            alpha = 0.6
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let wasPressed = isButtonPressed
        isButtonPressed = false
        if state != .disabled {
            alpha = 1.0
        }
        if wasPressed, let touch = touches.first, let parentNode = self.parent,
           contains(touch.location(in: parentNode)) {
            onPressed()
        }
    }

    //Called when the OS interrupts the user, eg display a dialog
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isButtonPressed = false
        if state != .disabled {
            alpha = 1.0
        }
    }
}
