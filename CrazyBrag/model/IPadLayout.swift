//
//  TableLayout.swift
//  Cards
//
//  Created by Mark Bailey on 22/06/2023.
//
import Foundation

///Z-Positioning for the game 
enum Layer : CGFloat {
    case background, tableMat, ui, messages, card1, card2, card3, deck
}

struct GameFonts {
    let nameFontSize : CGFloat
    let livesFontSize : CGFloat
    let buttonFontSize : CGFloat
    let dealerFontSize : CGFloat
    let statusFontSize : CGFloat
}

protocol TableLayout {
    var size : CGSize { get }
    var fonts : GameFonts { get }
    var cardSize : CGSize { get }
    var message : CGPoint { get }
    var deckPosition : CGPoint { get }
    func getNamePosition(seat : Int) -> CGPoint
    func getLivesPosition(seat : Int) -> CGPoint
    func getDealerPosition(seat : Int) -> CGPoint
    func getPosition(dealt : DealtCard) -> CGPoint
    func getFrame(seat : Int) -> CGRect
}

struct IPadLayout : TableLayout {
    static let CARD_WIDTH : Double = 100
    static let CARD_HEIGHT : Double = 153

    //iPad 6th Gen logical screen size
    let size = CGSize(width: 1024.0, height: 768.0)
    let cardSize = CGSize(width: CARD_WIDTH, height: CARD_HEIGHT)
    let fonts =  GameFonts(
        nameFontSize: 24.0, livesFontSize: 18.0, buttonFontSize: 36.0,
        dealerFontSize: 36.0, statusFontSize: 28.0)
    let deckPosition = CGPoint(x: 100, y: 100)
    let message = CGPoint(x: 872.0, y: 120.0)

    private let box = CGRect(x: 352.0, y: 307.5, width: 3.0 * (CARD_WIDTH + 7.0), height: CARD_HEIGHT)
    private let player = CGRect(x: 352.0, y: 38.0, width: 3.0 * (CARD_WIDTH + 7.0), height: CARD_HEIGHT)
    private let cpuWest = CGRect(x: 51.0, y: 308.0, width: 2.0 * CARD_WIDTH, height: CARD_HEIGHT)
    private let cpuEast = CGRect(x: 772.0, y: 308.0, width: 2.0 * CARD_WIDTH, height: CARD_HEIGHT)
    private let cpuNorth = CGRect(x: 412.0, y: 570.0, width: 2.0 * CARD_WIDTH, height: CARD_HEIGHT)
    private let cpuNorthWest = CGRect(x: 60.0, y: 570.0, width: 2.0 * CARD_WIDTH, height: CARD_HEIGHT)
    private let cpuNorthEast = CGRect(x: 764.0, y: 570.0, width: 2.0 * CARD_WIDTH, height: CARD_HEIGHT)

    private let yNameOffset : CGFloat = 8.0

    func getNamePosition(seat : Int) -> CGPoint {
        return getCardPosition(for: seat).namePos
    }
    
    func getLivesPosition(seat : Int) -> CGPoint {
        return getCardPosition(for: seat).livesPos
    }

    func getDealerPosition(seat : Int) -> CGPoint {
        return getCardPosition(for: seat).dealerTokenPos
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
            return CardPosition(frame: cpuNorth, cardSize: cardSize, yNameOffset: yNameOffset)
        case 4:
            return CardPosition(frame: cpuNorthEast, cardSize: cardSize, yNameOffset: yNameOffset)
        case 5:
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

struct CardPosition {
    let frame : CGRect
    let position1 : CGPoint
    let position2 : CGPoint
    let position3 : CGPoint
    let namePos : CGPoint
    let livesPos : CGPoint
    let dealerTokenPos : CGPoint

    internal init(frame: CGRect, cardSize: CGSize, yNameOffset: CGFloat) {
        self.frame = frame
        position1 = CGPoint(x: cardSize.width / 2.0 + frame.origin.x, y: frame.midY)
        position2 = CGPoint(x: frame.midX, y: frame.midY)
        position3 = CGPoint(x: frame.maxX - cardSize.width / 2.0, y: frame.midY)
        namePos = CGPoint(x: frame.origin.x, y: frame.maxY + yNameOffset)
        livesPos = CGPoint(x: frame.maxX, y: frame.maxY + yNameOffset)
        dealerTokenPos = CGPoint(x: frame.origin.x - 10.0, y: frame.midY)
    }
}
