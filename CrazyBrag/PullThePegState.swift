//
//  PullThePegState.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

class PullThePegState : BasePlayState {
    let outPlayers: [Player]
    
    init(_ presenter: GamePresenter, outPlayers: [Player]) {
        self.outPlayers = outPlayers
        super.init(presenter)
    }
    
    override func enter() {
        switch outPlayers.count {
        case 0:
            presenter.view?.show(message: "")
        case 1:
            if outPlayers[0].seat == 0{
                presenter.view?.show(message: "You are out")
            } else{
                presenter.view?.show(message: "\(outPlayers.first?.name ?? "")\nIs Out")
            }
        default:
            presenter.view?.show(message: "\(outPlayers.count) Players\nAre Out")
        }
        for player in outPlayers {
            presenter.view?.removePlayer(player: player)
        }
    }
    
    override func update() {
        presenter.model.updateState()
    }
}
