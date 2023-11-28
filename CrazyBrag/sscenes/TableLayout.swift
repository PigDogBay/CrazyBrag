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
    var position1 : CGPoint { get }
    var position2 : CGPoint { get }
    var position3 : CGPoint { get }
    var namePos : CGPoint { get }
    var livesPos : CGPoint { get }
}

struct TableLayout {
    
    let size : CGSize
    
    var boxLayout : BoxLayout { BoxLayout(frame: box, cardSize: cardSize)}
    var playerLayout : BoxLayout {BoxLayout(frame: player, cardSize: cardSize)}
    var cpuWestLayout : CPULayout {CPULayout(frame: cpuWest, cardSize: cardSize)}
    var cpuEastLayout : CPULayout {CPULayout(frame: cpuEast, cardSize: cardSize)}
    var cpuNorthLayout : CPULayout {CPULayout(frame: cpuNorth, cardSize: cardSize)}
    var cpuNorthWestLayout : CPULayout {CPULayout(frame: cpuNorthWest, cardSize: cardSize)}
    var cpuNorthEastLayout : CPULayout {CPULayout(frame: cpuNorthEast, cardSize: cardSize)}
    
    var deckPosition : CGPoint {
        return CGPoint(x: 100, y: cardSize.height)
    }
    
    var box : CGRect {
        let w = cardSize.width * 3.2
        let h = cardSize.height
        let x = (size.width - w) / 2.0
        let y = (size.height - h) / 2.0
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    var player : CGRect {
        let w = cardSize.width * 3.2
        let h = cardSize.height
        let x = (size.width - w) / 2.0
        let y = size.height * 0.05
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    var cpuWest : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.05
        let y = (size.height - h) / 2.0
        return CGRect(x: x, y: y, width: w, height: h)
    }

    var cpuEast : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.95 - w
        let y = (size.height - h) / 2.0
        return CGRect(x: x, y: y, width: w, height: h)
    }

    var cpuNorth : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = (size.width - w) / 2.0
        let y = size.height * 0.95 - h
        return CGRect(x: x, y: y, width: w, height: h)
    }

    var cpuNorthWest : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.05
        let y = size.height * 0.95 - h
        return CGRect(x: x, y: y, width: w, height: h)
    }

    var cpuNorthEast : CGRect {
        let w = cardSize.width * 2.0
        let h = cardSize.height
        let x = size.width * 0.95 - w
        let y = size.height * 0.95 - h
        return CGRect(x: x, y: y, width: w, height: h)
    }

    var cardSize : CGSize {
        let w : Double = size.width / 10.0
        let h : Double = w * (CARD_ASSET_HEIGHT/CARD_ASSET_WIDTH)
        return CGSize(width: w, height: h)
    }

    func getNamePosition(seat : Int) -> CGPoint {
        return getCardPosition(for: seat).namePos
    }
    
    func getLivesPosition(seat : Int) -> CGPoint {
        return getCardPosition(for: seat).livesPos
    }
    
    func getPosition(dealt : DealtCard) -> CGPoint {
        return getPosition(cardPosition: getCardPosition(for: dealt.seat), index: dealt.cardCount)

    }

    private func getCardPosition(for seat : Int) -> CardPosition {
        switch (seat){
        case -1:
            return boxLayout
        case 0:
            return playerLayout
        case 1:
            return cpuWestLayout
        case 2:
            return cpuNorthWestLayout
        case 3:
            return cpuNorthLayout
        case 4:
            return cpuNorthEastLayout
        case 5:
            return cpuEastLayout
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
        return CGPoint(x: frame.origin.x, y: frame.maxY + 8.0)
    }
    
    var livesPos : CGPoint {
        return CGPoint(x: frame.maxX, y: frame.maxY + 8.0)
    }


}

struct CPULayout : CardPosition{
    let frame : CGRect
    let cardSize : CGSize
    
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
        return CGPoint(x: frame.origin.x, y: frame.maxY + 8.0)
    }
    
    var livesPos : CGPoint {
        return CGPoint(x: frame.maxX, y: frame.maxY + 8.0)
    }

}
