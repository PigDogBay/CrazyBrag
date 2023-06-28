//
//  Player.swift
//  CardGames
//
//  Created by Mark Bailey on 09/09/2022.
//

import Foundation



class Player : Equatable {
    let name : String
    let hand = PlayerHand()
    var lives = 3
    var score = BragHandScore(type: .high, score: 0)
    var seat = 0
    let ai : AI
    var gamesWon = 0
    
    init(name : String, ai : AI){
        self.name = name
        self.ai = ai
        ai.player = self
    }
    
    func play(middle : PlayerHand) -> Turn{
        let turn = ai.play(middle: middle)
        hand.play(turn: turn, middle: middle)
        hand.hide()
        return turn
    }
    
    func resolveHand(){
        score = hand.score
    }
    
    ///Equatable, each player must have an unique seat
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.seat == rhs.seat
    }
}
