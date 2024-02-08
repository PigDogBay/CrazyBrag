//
//  ShowHandsState.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

class ShowHandsState : BasePlayState {
    let players: [Player]
    
    init(_ presenter: GamePresenter, players: [Player]) {
        self.players = players
        super.init(presenter)
    }
    
    override func enter() {
        presenter.view?.show(message: "End of Round\nWorst Hand Loses")
        presenter.gameUpdateFrequency = 2.5
        for player in presenter.model.school.players{
            presenter.showCards(in: player.hand)
        }

        //Reveal the facedown middle card
        if let hiddenCard = presenter.model.middle.hand.first{
            presenter.view?.turn(card: hiddenCard, isFaceUp: true)
        }
    }
    
    override func update() {
        presenter.model.updateState()
    }
}
