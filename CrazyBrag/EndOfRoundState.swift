//
//  EndOfRound.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

///Wait for human player to press the continue button
class EndOfRoundState : BasePlayState {
    let losingPlayers: [Player]
    init(_ presenter : GamePresenter, losingPlayers: [Player]){
        self.losingPlayers = losingPlayers
        super.init(presenter)
    }

    override func enter() {
        switch losingPlayers.count {
        case 0:
            presenter.view?.show(message: "")
        case 1:
            if losingPlayers[0].seat == 0{
                presenter.view?.show(message: "You lose a life")
            } else{
                presenter.view?.show(message: "\(losingPlayers.first?.name ?? "")\nLoses a life")
            }
        default:
            presenter.view?.show(message: "\(losingPlayers.count) Players\nLose a life")
        }
        for player in losingPlayers {
            presenter.view?.updateScore(player: player)
        }

        presenter.view?.play(soundNamed: "LoseLife")
        //Player must press the continue button
        presenter.view?.continueButton(show: true)
        presenter.gameUpdateFrequency = 0.5
    }
    
#if DEBUG
    var counter = 0
    override func update() {
        counter = counter + 1
        if DEBUG_AUTO_PLAY && counter == 5 {
            presenter.continueGame()
        }
    }
#endif
  
    override func exit(){
        presenter.view?.play(soundNamed: "card")
        presenter.view?.continueButton(show: false)
    }
}
