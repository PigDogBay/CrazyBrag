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
    let model : Model
    init(model: Model) {
        self.model = model
    }
    func enter() {
        //Do nothing
    }
    
    func update() {
        model.updateState()
    }
}

///Wait for human player to take their turn
class HumanPlay : PlayState{
    func enter() {}
    func update() {}
}

///Wait for human player to press the continue button
class EndOfRound : PlayState{
    func enter() {}
    func update() {}
}
