//
//  DealingDoneState.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

class DealingDoneState : BasePlayState {
    let dealtCards: [DealtCard]
    
    init(_ presenter : GamePresenter, dealtCards: [DealtCard]) {
        self.dealtCards = dealtCards
        super.init(presenter)
    }
    
    override func enter() {
        presenter.gameUpdateFrequency = 2.5
        presenter.positionCard(cards: dealtCards, duration: 0.1)
    }
    
    override func update() {
        presenter.model.updateState()
    }
}
