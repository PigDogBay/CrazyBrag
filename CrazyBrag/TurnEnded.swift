//
//  TurnEnded.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 08/02/2024.
//

import Foundation


class TurnEnded : BasePlayState {
    let player : Player
    let middle : PlayerHand
    let turn : Turn
    
    init(_ presenter: GamePresenter, player: Player, middle: PlayerHand, turn: Turn) {
        self.player = player
        self.middle = middle
        self.turn = turn
        super.init(presenter)
    }
    
    override func enter() {
        presenter.gameUpdateFrequency = 2.5
        presenter.model.isPlayersTurn = false
        switch turn {
        case .swap(hand: let handCard, middle: let middleCard):
            //The player and middle hands will already be swapped in the model
            //however on screen they need to be moved
            //First find the index of the new card in the players hand
            let pIndex = player.hand.indexOf(card: middleCard)
            //Then find the index of the discarded card in the middle
            let mIndex = middle.indexOf(card: handCard)
            if pIndex != -1 && mIndex != -1 {
                //Move the sprites to their new positions
                let p = DealtCard(seat: player.seat, card: middleCard, cardCount: pIndex + 1)
                let m = DealtCard(card: handCard, cardCount: mIndex + 1)
                presenter.positionCard(cards: [p,m], duration: 0.5)

            }
        case .all(downIndex: _):
            //All card sprites need swapping
            let p1 = DealtCard(seat: player.seat, card: player.hand.hand[0], cardCount: 1)
            let p2 = DealtCard(seat: player.seat, card: player.hand.hand[1], cardCount: 2)
            let p3 = DealtCard(seat: player.seat, card: player.hand.hand[2], cardCount: 3)
            let m1 = DealtCard(card: middle.hand[0], cardCount: 1)
            let m2 = DealtCard(card: middle.hand[1], cardCount: 2)
            let m3 = DealtCard(card: middle.hand[2], cardCount: 3)
            presenter.positionCard(cards: [p1,p2,p3,m1,m2,m3], duration: 0.5)
        }
        if player.seat == 0{
            presenter.showCards(in: presenter.model.school.playerHuman.hand)
        }
        presenter.view?.highlight(player: player, status: .played)
    }
    
    override func update() {
        presenter.model.updateState()
    }
    
}
