//
//  TurnStartedState.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

///Computer player's turn
class TurnStartedState : BasePlayState {
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
        presenter.view?.show(message: "\(player.name)'s\nTurn")
    }
    
    override func update() {
        presenter.model.updateState()
    }
}
