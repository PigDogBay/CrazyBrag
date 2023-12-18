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
        let card1 = PlayingCard(suit: .spades, rank: .ace)
        let card2 = PlayingCard(suit: .hearts, rank: .two)
        let card3 = PlayingCard(suit: .clubs, rank: .three)
        switch state {
        case .deal:
            view?.setZ(card: card1, z: Layer.card1.rawValue)
            view?.setZ(card: card2, z: Layer.card2.rawValue)
            view?.setZ(card: card3, z: Layer.card3.rawValue)
            view?.actionMove(card: card1, pos: CGPoint(x: 450, y: 400), duration: 0.25) { [weak self] in
                self?.view?.actionMove(card: card2, pos: CGPoint(x: 475, y: 400), duration: 0.25){ [weak self] in
                    self?.view?.actionMove(card: card3, pos: CGPoint(x: 500, y: 400), duration: 0.25){ [weak self] in
                        self?.state = .show
                        self?.next()
                    }
                }
            }
        case .show:
            view?.actionTurnCard(card: card1, duration: 0.1){ [weak self] in
                self?.view?.actionTurnCard(card: card2, duration: 0.1){ [weak self] in
                    self?.view?.actionTurnCard(card: card3, duration: 0.1){ [weak self] in
                        self?.state = .wait
                        self?.next()
                    }
                }
            }
        case .wait:
            self.view?.actionWait(duration: 3.0){ [weak self] in
                self?.state = .gather
                self?.next()
            }
            break
        case .gather:
            let deckPos = self.tableLayout.deckPosition
            view?.actionGather(card: card1, pos: deckPos, duration: 0.1) { [weak self] in
                self?.view?.actionGather(card: card2, pos: deckPos, duration: 0.1){ [weak self] in
                    self?.view?.actionGather(card: card3, pos: deckPos, duration: 0.1){ [weak self] in
                        self?.state = .deal
                        self?.next()
                    }
                }
            }
        }
    }
}
