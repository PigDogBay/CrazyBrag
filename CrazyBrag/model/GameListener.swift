//
//  GameListener.swift
//  CardGames
//
//  Created by Mark Bailey on 28/09/2022.
//

import Foundation

protocol GameListener : AnyObject {
    func dealerSelected(dealer : Player)
    func dealingDone(dealtCards : [DealtCard])
    func reveal()
    func turnStarted(player : Player, middle : PlayerHand)
    ///Looky Looky rules: the player has taken one of the optional actions before making their move
    func actionTaken(player : Player, action : TurnActionResult)
    func turnEnded(player : Player, middle : PlayerHand, turn : Turn)
    func showHands(players : [Player])
    ///extraLife: Looky Looky rules, the player who has gained a life for their first winning prial,
    ///in which case nobody loses a life and losingPlayers is empty
    func roundEnded(losingPlayers : [Player], extraLife : Player?)
    func pullThePeg(outPlayers : [Player])
    func everyoneOutSoReplayRound()
    func gameOver(winner : Player)
}
