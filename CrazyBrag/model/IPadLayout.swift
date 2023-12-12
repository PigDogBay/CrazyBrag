//
//  TableLayout.swift
//  Cards
//
//  Created by Mark Bailey on 22/06/2023.
//

import Foundation

let CARD_ASSET_WIDTH : Double = 691.0
let CARD_ASSET_HEIGHT : Double = 1056.0

protocol CardPosition{
    var frame : CGRect {get}
    var position1 : CGPoint { get }
    var position2 : CGPoint { get }
    var position3 : CGPoint { get }
    var namePos : CGPoint { get }
    var livesPos : CGPoint { get }
    var dealerTokenPos : CGPoint { get }
}

///Z-Positioning for the game 
enum Layer : CGFloat {
    case background, tableMat, ui, card1, card2, card3, messages, deck
}

struct GamesFonts {
    let nameFontSize : CGFloat
    let livesFontSize : CGFloat
    let buttonFontSize : CGFloat
    let dealerFontSize : CGFloat
    let statusFontSize : CGFloat
}

struct IPadLayout {
    
    private let size : CGSize
    private let cardSizeDivisor : Double
    private let yNameOffset : CGFloat
    let isPhone : Bool
    let fonts : GamesFonts
    
    internal init(size: CGSize, isPhone: Bool) {
        self.size = size
        self.isPhone = isPhone
        if isPhone {
            self.fonts = GamesFonts(
                nameFontSize: 12.0, livesFontSize: 12.0, buttonFontSize: 18.0,
                dealerFontSize: 18.0, statusFontSize: 22.0)
            self.cardSizeDivisor = 14.0
            self.yNameOffset = 5.0
        } else {
            self.fonts = GamesFonts(
                nameFontSize: 24.0, livesFontSize: 18.0, buttonFontSize: 36.0,
                dealerFontSize: 36.0, statusFontSize: 28.0)
            self.cardSizeDivisor = 10.0
            self.yNameOffset = 8.0
        }
    }

    var deckPosition : CGPoint {
        return CGPoint(x: 100, y: cardSize.height)
    }
    
    private var box : CGRect {
        let w = cardSize.width * 3.2
        let h = cardSize.height
        let x = (size.width - w) / 2.0
        let y = (size.height - h) / 2.0
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    private var player : CGRect {
        let w = cardSize.width * 3.2
        let h = cardSize.height
        let x = (size.width - w) / 2.0
        let y = size.height * 0.05
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    private var cpuWest : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.05
        let y = (size.height - h) / 2.0
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private var cpuEast : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.95 - w
        let y = (size.height - h) / 2.0
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private var cpuNorth : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = (size.width - w) / 2.0
        let y = size.height * 0.95 - h
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private var cpuNorthWest : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.05
        let y = size.height * 0.95 - h
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private var cpuNorthEast : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.95 - w
        let y = size.height * 0.95 - h
        return CGRect(x: x, y: y, width: w, height: h)
    }

    var cardSize : CGSize {
        let w : Double = size.width / self.cardSizeDivisor
        let h : Double = w * (CARD_ASSET_HEIGHT/CARD_ASSET_WIDTH)
        return CGSize(width: w, height: h)
    }
    
    var message : CGPoint {
        return CGPoint(x: cpuEast.midX, y: player.midY)
    }

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
            return BoxLayout(frame: box, cardSize: cardSize, yNameOffset: yNameOffset)
        case 0:
            return BoxLayout(frame: player, cardSize: cardSize, yNameOffset: yNameOffset)
        case 1:
            return CPULayout(frame: cpuWest, cardSize: cardSize, yNameOffset: yNameOffset)
        case 2:
            return CPULayout(frame: cpuNorthWest, cardSize: cardSize, yNameOffset: yNameOffset)
        case 3:
            return CPULayout(frame: cpuNorth, cardSize: cardSize, yNameOffset: yNameOffset)
        case 4:
            return CPULayout(frame: cpuNorthEast, cardSize: cardSize, yNameOffset: yNameOffset)
        case 5:
            return CPULayout(frame: cpuEast, cardSize: cardSize, yNameOffset: yNameOffset)
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

struct BoxLayout : CardPosition {
    let frame : CGRect
    let cardSize : CGSize
    let yNameOffset : CGFloat

    var position1 : CGPoint {
        let w : CGFloat = frame.width
        return CGPoint(x: w/6.0 + frame.origin.x, y: frame.midY)
    }
    
    var position2 : CGPoint {
        let w : CGFloat = frame.width
        return CGPoint(x: w/2.0 + frame.origin.x, y: frame.midY)
    }
    
    var position3 : CGPoint {
        let w : CGFloat = frame.width
        return CGPoint(x: w*5.0/6.0 + frame.origin.x, y: frame.midY)
    }
    
    var namePos : CGPoint {
        return CGPoint(x: frame.origin.x, y: frame.maxY + yNameOffset)
    }
    
    var livesPos : CGPoint {
        return CGPoint(x: frame.maxX, y: frame.maxY + yNameOffset)
    }

    var dealerTokenPos : CGPoint {
        return CGPoint(x: frame.origin.x - 10.0, y: frame.midY)
    }
}

struct CPULayout : CardPosition{
    let frame : CGRect
    let cardSize : CGSize
    let yNameOffset : CGFloat
    
    var position1 : CGPoint {
        return CGPoint(x: cardSize.width/2.0 + frame.origin.x, y: frame.midY)
    }
    
    var position2 : CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY)
    }
    
    var position3 : CGPoint {
        return CGPoint(x: cardSize.width * 1.5 + frame.origin.x, y: frame.midY)
    }
    
    var namePos : CGPoint {
        return CGPoint(x: frame.origin.x, y: frame.maxY + yNameOffset)
    }
    
    var livesPos : CGPoint {
        return CGPoint(x: frame.maxX, y: frame.maxY + yNameOffset)
    }
    
    var dealerTokenPos : CGPoint {
        return CGPoint(x: frame.origin.x - 10.0, y: frame.midY)
    }

}
