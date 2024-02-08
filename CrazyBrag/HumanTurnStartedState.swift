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
        //Don't update the model
    }
}
