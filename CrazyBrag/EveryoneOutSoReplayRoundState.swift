//
//  EveryoneOutSoReplayRoundState.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

class EveryoneOutSoReplayRoundState : BasePlayState {
    
    override func enter() {
        presenter.view?.show(message: "A Draw\nDeal Again")
    }
    
    override func update() {
        presenter.model.updateState()
    }
}
