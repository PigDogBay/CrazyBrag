//
//  InformationLayout.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 22/12/2023.
//

import Foundation

struct InformationLayout {
    
    let frame : CGRect
    
    let titleFontSize : Double
    let bodyFontSize : Double
    let controlFontSize : Double
    let pageFontSize : Double
    let closeFontSize : Double
    let lineSpacing : CGFloat
    
    let titlePosition : CGPoint
    let bodyPosition : CGPoint
    let previousPosition : CGPoint
    let pagePosition : CGPoint
    let nextPosition : CGPoint
    let closePosition : CGPoint

    init(isPhone : Bool){
        if isPhone {
            frame = CGRect(x: 216, y: 15, width: 500.0, height: 400.0)
            titleFontSize = 32.0
            bodyFontSize = 20.0
            controlFontSize = 32.0
            pageFontSize = 18.0
            closeFontSize = 24.0
            lineSpacing = 10.0
            titlePosition = CGPoint(x: frame.midX, y: 360.0)
            bodyPosition = CGPoint(x: frame.midX, y: 225.0)
            previousPosition = CGPoint(x: 406.0, y: 40.0)
            nextPosition = CGPoint(x: 526, y: 40.0)
            pagePosition = CGPoint(x: 466, y: 45.0)
            closePosition = CGPoint(x: 698, y: 388)
        } else {
            frame = CGRect(x: 216, y: 15, width: 500.0, height: 400.0)
            titleFontSize = 32.0
            bodyFontSize = 18.0
            controlFontSize = 32.0
            pageFontSize = 18.0
            closeFontSize = 24.0
            lineSpacing = 10.0
            titlePosition = CGPoint(x: frame.midX, y: 360.0)
            bodyPosition = CGPoint(x: frame.midX, y: 225.0)
            previousPosition = CGPoint(x: 406.0, y: 40.0)
            nextPosition = CGPoint(x: 526, y: 40.0)
            pagePosition = CGPoint(x: 466, y: 45.0)
            closePosition = CGPoint(x: 698, y: 388)
        }
    }
}
