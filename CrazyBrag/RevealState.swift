//
//  RevealState.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

class RevealState : BasePlayState {

    override func enter() {
        presenter.showCards(in: presenter.model.school.playerHuman.hand)
        //Hide the deck
        for card in presenter.model.deck.deck{
            presenter.view?.setZPosition(on: card, z: -1.0)
        }
    }
    
    override func update() {
        presenter.model.updateState()
    }
}
