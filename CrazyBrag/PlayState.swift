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

class NullPlay : PlayState{
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
class HumanPlay : PlayState{
    func enter() {}
    func update() {}
    func exit(){}
}

///Wait for human player to press the continue button
class EndOfRound : BasePlayState {
    override func enter() {
        presenter.view?.continueButton(show: true)
        presenter.gameUpdateFrequency = 0.5
    }
  
    override func exit(){
        presenter.view?.play(soundNamed: "card")
        presenter.view?.continueButton(show: false)
    }
}

class CollectCards : BasePlayState{
    override func enter() {
        presenter.gameUpdateFrequency = 0.5
    }
    override func update() {
        presenter.change(state: AutoPlay(presenter))
    }
}

