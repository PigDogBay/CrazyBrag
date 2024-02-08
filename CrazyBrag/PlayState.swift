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
