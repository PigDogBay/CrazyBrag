//
//  TableLayout.swift
//  Cards
//
//  Created by Mark Bailey on 22/06/2023.
//

import Foundation

let CARD_ASSET_WIDTH : Double = 691.0
let CARD_ASSET_HEIGHT : Double = 1056.0

struct TableLayout {
    
    let size : CGSize
    
    lazy var boxLayout = BoxLayout(frame: box, cardSize: cardSize)
    lazy var playerLayout = BoxLayout(frame: player, cardSize: cardSize)
    lazy var cpuWestLayout = CPULayout(frame: cpuWest, cardSize: cardSize)
    lazy var cpuEastLayout = CPULayout(frame: cpuEast, cardSize: cardSize)
    lazy var cpuNorthLayout = CPULayout(frame: cpuNorth, cardSize: cardSize)
    lazy var cpuNorthWestLayout = CPULayout(frame: cpuNorthWest, cardSize: cardSize)
    lazy var cpuNorthEastLayout = CPULayout(frame: cpuNorthEast, cardSize: cardSize)
    
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
}

struct BoxLayout {
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

struct CPULayout {
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
