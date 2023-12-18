//
//  StartPresenter.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 18/12/2023.
//

import Foundation

protocol StartView : AnyObject{
    func setZ(card : PlayingCard, z : CGFloat)
    func actionMove(card : PlayingCard, pos : CGPoint, duration : CGFloat, completion block: @escaping () -> Void)
    func actionGather(card : PlayingCard, pos : CGPoint, duration : CGFloat, completion block: @escaping () -> Void)
    func actionTurnCard(card : PlayingCard, duration : CGFloat, completion block: @escaping () -> Void)
    func actionWait(duration : CGFloat, completion block: @escaping () -> Void)
}

enum StartDemoStates {
    case deal, show, wait, gather
}

class StartPresenter {
    
    let deck = Deck()
    let tableLayout : TableLayout
    weak var view : StartView? = nil
    
    private var state : StartDemoStates = .deal

    let A23Run = [PlayingCard(suit: .clubs, rank: .two),
                PlayingCard(suit: .diamonds, rank: .three),
                PlayingCard(suit: .diamonds, rank: .ace)]

    
    init(isPhone : Bool){
        if isPhone {
            tableLayout = IPhoneLayout()
        } else {
            tableLayout = IPadLayout()
        }
        deck.createDeck()
    }
    
    func next(){
        print("next: \(state)")
        switch state {
        case .deal:
            view?.setZ(card: A23Run[0], z: Layer.card1.rawValue)
            view?.setZ(card: A23Run[1], z: Layer.card2.rawValue)
            view?.setZ(card: A23Run[2], z: Layer.card3.rawValue)
            view?.actionMove(card: A23Run[0], pos: CGPoint(x: 450, y: 400), duration: 0.25) {
                self.view?.actionMove(card: self.A23Run[1], pos: CGPoint(x: 475, y: 400), duration: 0.25){
                    self.view?.actionMove(card: self.A23Run[2], pos: CGPoint(x: 500, y: 400), duration: 0.25){
                        self.state = .show
                        self.next()
                    }
                }
            }
        case .show:
            view?.actionTurnCard(card: A23Run[2], duration: 0.1){
                self.view?.actionTurnCard(card: self.A23Run[1], duration: 0.1){
                    self.view?.actionTurnCard(card: self.A23Run[0], duration: 0.1){
                        self.state = .wait
                        self.next()
                    }
                }
            }
        case .wait:
            self.view?.actionWait(duration: 3.0){
                self.state = .gather
                self.next()
            }
            break
        case .gather:
            view?.actionGather(card: A23Run[0], pos: tableLayout.deckPosition, duration: 0.1) {
                self.view?.actionGather(card: self.A23Run[1], pos: self.tableLayout.deckPosition, duration: 0.1){
                    self.view?.actionGather(card: self.A23Run[2], pos: self.tableLayout.deckPosition, duration: 0.1){
                        self.state = .deal
                        self.next()
                    }
                }
            }
        }
    }
}
