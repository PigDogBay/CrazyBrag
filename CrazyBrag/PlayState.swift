//
//  GameState.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

protocol PlayState {
    func enter()
    func update()
    func exit()
}
class BasePlayState : PlayState {
    let presenter : GamePresenter
    init(_ presenter: GamePresenter) {
        self.presenter = presenter
    }
    func enter() {}
    func update() {}
    func exit(){}
}

class NullState : PlayState{
    func enter() {}
    func update() {}
    func exit(){}
}

class AutoPlay : BasePlayState {
    override func enter() {
        presenter.gameUpdateFrequency = 2.5
    }
    
    override func update() {
        presenter.model.updateState()
    }
}

///Wait for human player to take their turn
class HumanPlayersTurnState : PlayState{
    func enter() {}
    func update() {}
    func exit(){}
}


class CollectCards : BasePlayState{
    override func enter() {
        presenter.gameUpdateFrequency = 0.5
    }
    override func update() {
        presenter.change(state: AutoPlay(presenter))
    }
}

