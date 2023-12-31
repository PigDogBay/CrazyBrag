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
    private let handNameNode = SKLabelNode(fontNamed: "QuentinCaps")

    override init(){
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        self.presenter = StartPresenter(isPhone: isPhone)
        super.init(size: presenter.startLayout.size)
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
        addHandName()
        createCardNodes()
        addStartButton()
        presenter.next()
        addRulesButton()
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
            CardSpriteNode(card: $0, cardSize: presenter.startLayout.cardSize)
        }
        var z = Layer.deck.rawValue
        for card in cardNodes {
            card.position = presenter.startLayout.deckPos
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
        topLabel.fontSize = presenter.startLayout.titleFontSize
        topLabel.position = presenter.startLayout.titlePos
        topLabel.zPosition = Layer.messages.rawValue
        addChild(topLabel)
    }

    private func addHandName(){
        handNameNode.text = ""
        handNameNode.fontColor = SKColor.black
        handNameNode.fontSize = presenter.startLayout.nameFontSize
        handNameNode.position = presenter.startLayout.namePos
        handNameNode.zPosition = Layer.messages.rawValue
        handNameNode.alpha = 0.0
        addChild(handNameNode)
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
        background.anchorPoint = presenter.startLayout.backgroundAnchor
        background.position = CGPoint(x: frame.maxX, y: frame.maxY)
        background.zPosition = Layer.background.rawValue
        addChild(background)
    }
    
    private func addRulesButton(){
        let button = ButtonNode(label: "HELP", fontSize: presenter.startLayout.buttonFontSize){ [weak self] in
            if self?.childNode(withName: "instructions") == nil {
                self?.showInstructions()
            }
        }
        button.position = presenter.startLayout.rulesButtonPos
        button.zPosition = Layer.ui.rawValue
        addChild(button)
    }

    private func addStartButton(){
        let button = ButtonNode(label: "DEAL", fontSize: presenter.startLayout.buttonFontSize){ [weak self] in
            self?.startGame()
        }
        button.position = presenter.startLayout.dealButtonPos
        button.zPosition = Layer.ui.rawValue
        addChild(button)
    }
    
    private func showInstructions(){
        let infoNode = InformationNode()
        infoNode.name = "instructions"
        infoNode.zPosition = 1000
        addChild(infoNode)
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
    
    func actionFadeInName(name: String, duration: CGFloat) {
        handNameNode.text = name
        handNameNode.run(SKAction.fadeIn(withDuration: duration))
    }
    
    func actionFadeOutName(duration: CGFloat) {
        handNameNode.run(SKAction.fadeOut(withDuration: duration))
    }
}
