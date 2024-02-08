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
}

class NullPlay : PlayState{
    func enter() {}
    func update() {}
}

class AutoPlay : PlayState {
    let presenter : GamePresenter
    init(_ presenter: GamePresenter) {
        self.presenter = presenter
    }
    func enter() {
        presenter.gameUpdateFrequency = 2.5
    }
    
    func update() {
        presenter.model.updateState()
    }
}

///Wait for human player to take their turn
class HumanPlay : PlayState{
    func enter() {}
    func update() {}
}

///Wait for human player to press the continue button
class EndOfRound : PlayState{
    let presenter : GamePresenter
    init(_ presenter: GamePresenter) {
        self.presenter = presenter
    }
    func enter() {
        presenter.view?.continueButton(show: true)
        presenter.gameUpdateFrequency = 0.5
    }
    func update() {}
}

class CollectCards : PlayState{
    let presenter : GamePresenter
    init(_ presenter: GamePresenter) {
        self.presenter = presenter
    }
    func enter() {
        presenter.view?.play(soundNamed: "card")
        presenter.view?.continueButton(show: false)
        presenter.gameUpdateFrequency = 0.5
    }
    func update() {
        presenter.change(state: AutoPlay(presenter))
    }
}

