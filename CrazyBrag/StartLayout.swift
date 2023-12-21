//
//  StartLayout.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 19/12/2023.
//

import Foundation

struct StartLayout {
    let size : CGSize
    let cardSize :CGSize

    let titleFontSize : Double
    let buttonFontSize : Double
    let nameFontSize : Double

    let spreadOffset : CGFloat
    let stepOffset : Int
    let cardX : Int
    let cardY : Int

    let backgroundAnchor : CGPoint
    let deckPos : CGPoint
    let titlePos : CGPoint
    let namePos : CGPoint
    let dealButtonPos : CGPoint
    let rulesButtonPos : CGPoint

    func cardPosition(index : Int) -> CGPoint{
        let x = cardX + index * stepOffset
        return CGPoint(x: x, y: cardY)
    }
    
    init(isPhone : Bool){
        if isPhone {
            //IPhone 15 Pro Max logical screen size
            size = CGSize(width: 932.0, height: 430.0)
            cardSize = CGSize(width: 85.0, height: 130.0)
            titleFontSize = 64.0
            buttonFontSize = 36.0
            nameFontSize = 28.0
            spreadOffset = 50.0
            stepOffset = 25
            cardX = 441
            cardY = 210
            backgroundAnchor = CGPoint(x: 0.85, y: 0.9)
            deckPos = CGPoint(x: 150.0, y: 120.0)
            titlePos = CGPoint(x: 466.0, y: 340.0)
            namePos = CGPoint(x: 466.0, y: 70.0)
            dealButtonPos = CGPoint(x: 800.0, y: 70.0)
            rulesButtonPos = CGPoint(x: 800.0, y: 190.0)
        } else {
            //iPad 6th Gen logical screen size
            size = CGSize(width: 1024.0, height: 768.0)
            cardSize = CGSize(width: 119.0, height: 182.0)
            titleFontSize = 96.0
            buttonFontSize = 48.0
            nameFontSize = 44.0
            spreadOffset = 50.0
            stepOffset = 25
            cardX = 487
            cardY = 400
            backgroundAnchor = CGPoint(x: 0.85, y: 0.9)
            deckPos = CGPoint(x: 100.0, y: 100.0)
            titlePos = CGPoint(x: 512.0, y: 576.0)
            namePos = CGPoint(x: 512.0, y: 220.0)
            dealButtonPos = CGPoint(x: 512.0, y: 130.0)
            rulesButtonPos = CGPoint(x: 700.0, y: 130.0)
        }
    }
}
