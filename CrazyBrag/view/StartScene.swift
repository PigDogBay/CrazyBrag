//
//  StartScene.swift
//  Cards
//
//  Created by Mark Bailey on 22/06/2023.
//

import Foundation
import SpriteKit
import AVFoundation

class StartScene: SKScene {
    let musicAudioNode = SKAudioNode(fileNamed: "honky-tonk.wav")
    private var audioPlayer : AVAudioPlayer? = nil
    private var cardNodes = [CardSpriteNode]()
    private let presenter : StartPresenter
    
    override init(){
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        self.presenter = StartPresenter(isPhone: isPhone)
        super.init(size: presenter.tableLayout.size)
        self.scaleMode = .fill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        addMusic()
        addBackground(imageNamed: "treestump")
        addTitle()
        createCardNodes()
        addStartButton()
#if DEBUG
        autoPlay()
#endif
    }
    
#if DEBUG
    deinit{
        print("StartScene DEINIT")
    }
    private func autoPlay(){
        if DEBUG_AUTO_PLAY{
            let startAction = SKAction.run {[unowned self] in
                self.startGame()
            }
            let wait = SKAction.wait(forDuration: 3.0)
            run(SKAction.sequence([wait,startAction]))
        }
    }
#endif
    
    private func createCardNodes() {
        cardNodes = presenter.deck.deck.map {
            CardSpriteNode(card: $0, cardSize: presenter.tableLayout.cardSize)
        }
        var z = Layer.deck.rawValue
        for card in cardNodes {
            card.position = presenter.tableLayout.deckPosition
            card.zPosition = z
            z += 1
            addChild(card)
        }
    }
    
    private func addMusic(){
        audioEngine.mainMixerNode.outputVolume = 0.0
        musicAudioNode.autoplayLooped = true
        musicAudioNode.isPositional = false
        addChild(musicAudioNode)
        //Mute then fade in music
        musicAudioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
        run(SKAction.wait(forDuration: 1.0)){[unowned self] in
            self.audioEngine.mainMixerNode.outputVolume = 0.50
            self.musicAudioNode.run(SKAction.changeVolume(to: 0.1, duration: 5.0))
        }
    }
    
    private func addTitle(){
        let topLabel = SKLabelNode(fontNamed: "QuentinCaps")
        topLabel.text = "Crazy Brag"
        topLabel.fontColor = SKColor.black
        topLabel.fontSize = 48
        topLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        topLabel.zPosition = Layer.messages.rawValue
        addChild(topLabel)
    }
    
    private func playSound(named: String, volume : Float){
        let path = Bundle.main.path(forResource: named, ofType: nil)!
        let url = URL(fileURLWithPath: path)
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.volume = volume
        audioPlayer?.play()
    }
    
    private func startGame(){
        playSound(named: "ricochet.mp3", volume: 0.05)
        let transition = SKTransition.doorway(withDuration: 1.25)
        self.view?.presentScene(GameScene(size: self.frame.size), transition: transition)
    }

    private func addBackground(imageNamed image : String){
        let background = SKSpriteNode(imageNamed: image)
        background.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        background.position = CGPoint(x: frame.maxX, y: frame.maxY)
        background.zPosition = Layer.background.rawValue
        addChild(background)
    }
    
    private func addStartButton(){
        let button = ButtonNode(label: "DEAL", fontSize: 36.0){ [weak self] in
            self?.startGame()
        }
        button.position = CGPoint(x: frame.midX, y: frame.height * 0.2 )
        button.zPosition = Layer.ui.rawValue
        addChild(button)
    }
}
