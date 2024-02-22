//
//  GameViewController.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/06/2023.
//

import UIKit
import SpriteKit
import GameplayKit

#if DEBUG
let DEBUG_AUTO_PLAY = false
#endif

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            //The view size is the logical size (eg pixel resolution / scale factor):
            //iPhone 15 Pro Max - 430 x 932, ratio 0.46
            //iPhone 12 - 390 x 844, ratio 0.46
            //iPhone SE 3 - 375 x 667, ratio 0.56
            //iPad Pro 6 12.9" - 1024 x 1336, 0.75
            //iPad Air 5 - 820 x 1180, 0.69
            //iPad Mini 6 - 744 x 1133, 0.66
            let scene = StartScene()
            
            // Present the scene
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            
#if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
#endif
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
