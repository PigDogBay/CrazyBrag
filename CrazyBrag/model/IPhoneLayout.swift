//
//  IPhoneLayout.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 12/12/2023.
//

import Foundation


struct IPhoneLayout : TableLayout {
    let size : CGSize
    let yNameOffset : CGFloat = 5.0
    
    var fonts : GameFonts { return GameFonts(
        nameFontSize: 16.0, livesFontSize: 12.0, buttonFontSize: 18.0,
        dealerFontSize: 26.0, statusFontSize: 22.0)
    }
    
    var deckPosition : CGPoint {
        return CGPoint(x: 150, y: 0)
    }

    var cardSize : CGSize {
        let w : Double = size.width / 11.0
        let h : Double = w * (CARD_ASSET_HEIGHT/CARD_ASSET_WIDTH)
        return CGSize(width: w, height: h)
    }
    
    var message : CGPoint {
        let x = size.width / 2
        let y = size.height / 2 - 10
        return CGPoint(x: x, y: y)
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
    
    private var box : CGRect {
        let w = cardSize.width * 3.2
        let h = cardSize.height
        let x = (size.width - w) / 2.0
        let y = (size.height - h) - 20
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    private var player : CGRect {
        let w = cardSize.width * 3.2
        let h = cardSize.height
        let x = (size.width - w) / 2.0
        let y = size.height * 0.05 + 10
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    private var cpuWest : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.060
        let y = (size.height - h) / 2.0 - 60
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private var cpuEast : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.95 - w
        let y = (size.height - h) / 2.0 - 60
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private var cpuSouthEast : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.95 - w
        let y = size.height * 0.05
        return CGRect(x: x, y: y, width: w, height: -h * 2)
    }

    private var cpuNorthWest : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.075
        let y = size.height * 0.95 - h - 10
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private var cpuNorthEast : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.95 - w
        let y = size.height * 0.95 - h - 10
        return CGRect(x: x, y: y, width: w, height: h)
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
            return CPULayout(frame: cpuNorthEast, cardSize: cardSize, yNameOffset: yNameOffset)
        case 4:
            return CPULayout(frame: cpuEast, cardSize: cardSize, yNameOffset: yNameOffset)
        case 5:
            return CPULayout(frame: cpuSouthEast, cardSize: cardSize, yNameOffset: yNameOffset)
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
