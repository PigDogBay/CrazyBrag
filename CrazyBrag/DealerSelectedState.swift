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

    func allCardsToDeck(){
        let pos = presenter.tableLayout.deckPosition
        var z = Layer.deck.rawValue
        for card in presenter.model.deck.deck{
            presenter.view?.setZPosition(on: card, z: z)
            presenter.view?.turn(card: card, isFaceUp: false)
            z = z + 1
            presenter.view?.setPosition(on: card, pos: pos, duration: 0.5, delay: 0)
        }
    }

    override func enter() {
        presenter.view?.show(message: "\(dealer.name)\nDealing")
        presenter.gameUpdateFrequency = 1.0
        presenter.view?.updateDealer(player: dealer)
        allCardsToDeck()
        for player in presenter.model.school.players {
            presenter.view?.highlight(player: player, status: .ready)
        }
    }
    
    override func update() {
        presenter.model.updateState()
    }
}
