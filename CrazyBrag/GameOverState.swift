//
//  GameOverState.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

class GameOverState : BasePlayState {
    let winner: Player

    init(_ presenter: GamePresenter, winner: Player) {
        self.winner = winner
        super.init(presenter)
    }

    override func enter() {
        if winner.seat == 0 {
            //increase win count
            let settings = Settings()
            settings.gamesWon = settings.gamesWon + 1
            presenter.view?.show(message: "You are the Winner!")
        } else {
            presenter.view?.show(message: "\(winner.name) is the Winner!")
        }
#if DEBUG
        if DEBUG_AUTO_PLAY{
            presenter.quit()
        }
#endif
    }
}
