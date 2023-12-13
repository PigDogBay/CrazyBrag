//
//  IPhoneLayout.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 12/12/2023.
//

import Foundation


struct IPhoneLayout : TableLayout {
    static let CARD_WIDTH : Double = 85.0
    static let CARD_HEIGHT : Double = 130.0

    //IPhone 15 Pro Max logical screen size
    let size = CGSize(width: 932.0, height: 430.0)
    let cardSize = CGSize(width: CARD_WIDTH, height: CARD_HEIGHT)
    let message = CGPoint(x: 466.0, y: 207.0)
    let yNameOffset : CGFloat = 8.0
    let fonts = GameFonts(
        nameFontSize: 16.0, livesFontSize: 12.0, buttonFontSize: 18.0,
        dealerFontSize: 26.0, statusFontSize: 22.0)
    
    let deckPosition = CGPoint(x: 150, y: 0)
    let backButton = CGPoint(x: 900.0, y: 15.0)

    private let box = CGRect(x: 330.0, y: 280.0, width: 3.0 * (CARD_WIDTH + 6.0), height: CARD_HEIGHT)
    private let player = CGRect(x: 330.0, y: 32.0, width: 3.0 * (CARD_WIDTH + 6.0), height: CARD_HEIGHT)
    private let cpuWest = CGRect(x: 56.0, y: 80.0, width: 2.0*CARD_WIDTH, height: CARD_HEIGHT)
    private let cpuEast = CGRect(x: 715.0, y: 80.0, width: 2.0*CARD_WIDTH, height: CARD_HEIGHT)
    private let cpuNorthWest = CGRect(x: 70.0, y: 264.0, width: 2.0*CARD_WIDTH, height: CARD_HEIGHT)
    private let cpuNorthEast = CGRect(x: 701.0, y: 264.0, width: 2.0*CARD_WIDTH, height: CARD_HEIGHT)

    func getNamePosition(seat : Int) -> CGPoint {
        return getCardPosition(for: seat).namePos
    }
    
    func getLivesPosition(seat : Int) -> CGPoint {
        return getCardPosition(for: seat).livesPos
    }

    func getDealerPosition(seat : Int) -> CGPoint {
        switch (seat){
        case 1:
            //Place dealer token on the inside
            return CGPoint(x: cpuWest.maxX + 40.0, y: cpuWest.midY)
        case 2:
            //Place dealer token on the inside
            return CGPoint(x: cpuNorthWest.maxX + 40.0, y: cpuNorthWest.midY)
        default:
            return getCardPosition(for: seat).dealerTokenPos
        }
    }

    func getPosition(dealt : DealtCard) -> CGPoint {
        return getPosition(cardPosition: getCardPosition(for: dealt.seat), index: dealt.cardCount)
    }
    
    func getFrame(seat : Int) -> CGRect {
        return getCardPosition(for: seat).frame
    }

    private func getCardPosition(for seat : Int) -> CardPosition {
        switch (seat){
        case -1:
            return CardPosition(frame: box, cardSize: cardSize, yNameOffset: yNameOffset)
        case 0:
            return CardPosition(frame: player, cardSize: cardSize, yNameOffset: yNameOffset)
        case 1:
            return CardPosition(frame: cpuWest, cardSize: cardSize, yNameOffset: yNameOffset)
        case 2:
            return CardPosition(frame: cpuNorthWest, cardSize: cardSize, yNameOffset: yNameOffset)
        case 3:
            return CardPosition(frame: cpuNorthEast, cardSize: cardSize, yNameOffset: yNameOffset)
        case 4:
            return CardPosition(frame: cpuEast, cardSize: cardSize, yNameOffset: yNameOffset)
        default:
            fatalError("Bad seat position \(seat)")
        }
    }
    
    private func getPosition(cardPosition : CardPosition, index : Int) -> CGPoint {
        switch (index){
        case 1:
            return cardPosition.position1
        case 2:
            return cardPosition.position2
        case 3:
            return cardPosition.position3
        default:
            fatalError("Bad index \(index)")
        }
    }
}
