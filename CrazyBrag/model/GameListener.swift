//
//  GameListener.swift
//  CardGames
//
//  Created by Mark Bailey on 28/09/2022.
//

import Foundation

protocol GameListener {
    func dealerSelected(dealer : Player)
    func dealingDone(dealtCards : [DealtCard])
    func turnStarted(player : Player, middle : PlayerHand)
    func turnEnded(player : Player, middle : PlayerHand, turn : Turn)
    func showHands(players : [Player])
    func roundEnded(losingPlayers : [Player])
    func pullThePeg(outPlayers : [Player])
    func everyoneOutSoReplayRound()
    func gameOver(winner : Player)
}
