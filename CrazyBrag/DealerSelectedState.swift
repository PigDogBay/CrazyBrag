//
//  DealerSelectedState.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

class DealerSelectedState : BasePlayState {
    let dealer: Player
    
    init(_ presenter : GamePresenter, dealer: Player) {
        self.dealer = dealer
        super.init(presenter)
    }
    
    override func enter() {
        presenter.view?.show(message: "\(dealer.name)\nDealing")
        presenter.gameUpdateFrequency = 0.5
        presenter.view?.updateDealer(player: dealer)
        presenter.allCardsToDeck()
        for player in presenter.model.school.players {
            presenter.view?.highlight(player: player, status: .ready)
        }
    }
    
    override func update() {
        presenter.model.updateState()
    }
}
