//
//  HumanTurnStarted.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

class HumanTurnStartedState : BasePlayState {
    let player: Player
    let middle: PlayerHand
    var counter = 0
    
    init(_ presenter: GamePresenter, player: Player, middle: PlayerHand) {
        self.player = player
        self.middle = middle
        super.init(presenter)
    }
    
    override func enter() {
        presenter.gameUpdateFrequency = 1
        presenter.view?.highlight(player: player, status: .turn)
        //Player can now interact with the cards
        presenter.model.isPlayersTurn = true
        presenter.view?.show(message: "Your Turn")
    }
    
    override func update() {
        counter = counter + 1
        switch (counter) {
#if DEBUG
        case 1:
            if DEBUG_AUTO_PLAY {
                presenter.autoPlay()
            }
#endif
        case 5:
            presenter.view?.show(message: "Select 1 Card\nFrom Your Hand")
        case 9:
            presenter.view?.show(message: "Then 1 Card\nFrom The Middle")
        case 13:
            presenter.view?.show(message: "Or Select 3 Cards\nTo swap them all")
        case 17:
            counter = 0
            presenter.view?.show(message: "Your Turn")
        default:
            break
        }
    }
}
