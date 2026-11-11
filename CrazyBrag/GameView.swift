//
//  GameView.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation

protocol GameView {
    func quit()
    func setZPosition(on card: PlayingCard, z : CGFloat)
    func setPosition(on card: PlayingCard, pos: CGPoint, duration : TimeInterval, delay : TimeInterval)
    func addName(name : String, pos : CGPoint)
    func turn(card: PlayingCard, isFaceUp : Bool)
    func addLives(name : String, pos : CGPoint)
    func addTableMat(seat : Int)
    func updateScore(player : Player)
    func extraLife(player : Player)
    func updateDealer(player : Player)
    func removePlayer(player : Player)
    func highlight(player : Player, status : PlayerStatus)
    func show(message : String)
    func play(soundNamed : String)
    func continueButton(show : Bool)
    ///Move a stashed card back to the deck and out of sight
    func discard(card: PlayingCard, pos: CGPoint, duration : TimeInterval)
    ///Looky Looky rules: show whether one of the action buttons can be pressed
    func setActionButton(action : TurnAction, state : ActionButtonState)
}

protocol DialogView {
    func showMessage(title : String, message : String)
}
