//
//  ButtonNode.swift
//  SpriteResearch
//
//  Created by Mark Bailey on 23/11/2023.
//

import SpriteKit

class ButtonNode : SKShapeNode {
    let buttonTextNode = SKLabelNode(fontNamed: "QuentinCaps")
    let onPressed : ()->Void
    var isButtonPressed = false
    
    init(label : String, fontSize : Double, onPressed : @escaping ()->Void){
        self.onPressed = onPressed
        super.init()
        isUserInteractionEnabled = true
        buttonTextNode.text = label
        buttonTextNode.fontSize = fontSize
        buttonTextNode.fontColor = SKColor.black
        buttonTextNode.verticalAlignmentMode = .center
        fillColor = UIColor(white: 1.0, alpha: 0.25)
        strokeColor = .clear
        let w = buttonTextNode.frame.size.width+30
        let h = buttonTextNode.frame.size.height+30
        
        //Create path so that the rect is centered
        path = UIBezierPath(roundedRect: CGRect(x: -w/2, y: -h/2, width: w, height: h), cornerRadius: 10).cgPath
        addChild(buttonTextNode)
        buttonNotPressed()
    }
    
    func buttonPressed(){
        fillColor = UIColor(white: 1.0, alpha: 0.75)
        glowWidth = 10
        isButtonPressed = true
    }
    func buttonNotPressed(){
        fillColor = UIColor(white: 1.0, alpha: 0.25)
        glowWidth = 1
        isButtonPressed = false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonPressed()
    }
    
    //Ensure touch up is inside the button
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let parentNode = self.parent {
            if contains(touch.location(in: parentNode)) && isButtonPressed {
                isButtonPressed = false
                onPressed()
            }
        }
        buttonNotPressed()
    }
    
    //Called when the OS interrupts the user, eg display a dialog
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonNotPressed()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
