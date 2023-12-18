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
    func actionSpread(hand : [PlayingCard], byX : CGFloat, completion block: @escaping () -> Void)
    func actionWait(duration : CGFloat, completion block: @escaping () -> Void)
    func actionFadeInName(name : String, duration : CGFloat)
    func actionFadeOutName(duration : CGFloat)
}

enum StartDemoStates {
    case deal, show, spread, wait, gather, next
}

class StartPresenter {
    
    let deck = Deck()
    let tableLayout : TableLayout
    weak var view : StartView? = nil
    
    private var state : StartDemoStates = .deal
    private var exampleIndex = 0

    private var hand : [PlayingCard] {
        return ExampleHands[exampleIndex].hand
    }

    
    init(isPhone : Bool){
        if isPhone {
            tableLayout = IPhoneLayout()
        } else {
            tableLayout = IPadLayout()
        }
        deck.createDeck()
    }
    
    private func deal(index : Int){
        if index == 3 {
            state = .show
            next()
            return
        }
        let x = 500.0 + 25.0 * CGFloat(index)
        view?.setZ(card: hand[index], z: Layer.card1.rawValue + CGFloat(index))
        view?.actionMove(card: hand[index], pos: CGPoint(x: x, y: 400), duration: 0.25) { [weak self] in
            //Use recursion instead of nesting completion blocks (Pyramid of Doom)
            self?.deal(index: index + 1)
        }
    }
    
    private func turn(index : Int){
        if index == 3 {
            state = .spread
            next()
        } else {
            view?.actionTurnCard(card: hand[index], duration: 0.1){ [weak self] in
                self?.turn(index: index + 1)
            }
        }
    }
    
    private func gather(index : Int){
        if index == 3 {
            state = .next
            next()
        } else {
            view?.actionGather(card: hand[index], pos: tableLayout.deckPosition, duration: 0.1) { [weak self] in
                self?.gather(index: index + 1)
            }
        }
    }

    func next(){
        switch state {
        case .deal:
            deal(index: 0)
        case .show:
            turn(index: 0)
        case .spread:
            self.view?.actionSpread(hand: hand, byX: 50.0){[weak self] in
                self?.state = .wait
                self?.next()
            }
        case .wait:
            view?.actionFadeInName(name: ExampleHands[exampleIndex].name, duration: 2.0)
            self.view?.actionWait(duration: 3.0){ [weak self] in
                self?.state = .gather
                self?.next()
                self?.view?.actionFadeOutName(duration: 0.5)
            }
            break
        case .gather:
            gather(index: 0)
        case .next:
            exampleIndex += 1
            if exampleIndex == ExampleHands.count {
                exampleIndex = 0
            }
            state = .deal
            next()

        }
    }
}
