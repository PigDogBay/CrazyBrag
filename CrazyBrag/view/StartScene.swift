//
//  StartScene.swift
//  Cards
//
//  Created by Mark Bailey on 22/06/2023.
//

import Foundation
import SpriteKit
import AVFoundation

class StartScene: SKScene, StartView {
    
    let musicAudioNode = SKAudioNode(fileNamed: "honky-tonk.wav")
    private var audioPlayer : AVAudioPlayer? = nil
    private var cardNodes = [CardSpriteNode]()
    private let presenter : StartPresenter
    
    override init(){
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        self.presenter = StartPresenter(isPhone: isPhone)
        super.init(size: presenter.tableLayout.size)
        self.presenter.view = self
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
        presenter.next()
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
    
    ///MARK: - StartView
    
    func setZ(card : PlayingCard, z : CGFloat){
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            cardNode.zPosition = z
        }
    }

    func actionMove(card: PlayingCard, pos: CGPoint, duration: CGFloat, completion block: @escaping () -> Void) {
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            cardNode.run(SKAction.move(to: pos, duration: duration), completion: block)
        }
    }
    
    func actionTurnCard(card: PlayingCard, duration: CGFloat, completion block: @escaping () -> Void) {
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            let action = SKAction.run {
                cardNode.faceUp()
            }
            cardNode.run(SKAction.sequence([SKAction.wait(forDuration: duration), action]), completion: block)
        }
    }
    
    func actionGather(card: PlayingCard, pos: CGPoint, duration: CGFloat, completion block: @escaping () -> Void) {
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            cardNode.faceDown()
            cardNode.zRotation = 0.0
            cardNode.run(SKAction.move(to: pos, duration: duration), completion: block)
        }
    }
    
    func actionSpread(hand: [PlayingCard], byX : CGFloat, completion block: @escaping () -> Void) {
        let nodes = hand.compactMap{ card in
            cardNodes.first(where: {$0.playingCard == card})
        }
        let duration = 0.25
        let angle = CGFloat.pi / 12.0
        if nodes.count == 3 {
            nodes[0].run(SKAction.group([
                SKAction.moveTo(x: nodes[0].position.x - byX, duration: duration),
                SKAction.rotate(toAngle: angle, duration: duration)
            ]))
            nodes[1].run(SKAction.moveTo(y: nodes[1].position.y + byX/4, duration: duration))
            nodes[2].run(SKAction.group([
                SKAction.moveTo(x: nodes[2].position.x + byX, duration: duration),
                SKAction.rotate(toAngle: -angle, duration: duration)
            ]), completion: block)
        }
    }
    
    func actionWait(duration : CGFloat, completion block: @escaping () -> Void){
        run(SKAction.wait(forDuration: duration), completion: block)
    }
}
