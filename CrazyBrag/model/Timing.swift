//
//  Timing.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 30/06/2023.
//

import Foundation

public struct Timing {
    private let start = CFAbsoluteTimeGetCurrent()
    public init(){}
    
    public var elapsedSeconds : Double {
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    public func log() {
        print("Time taken: \(elapsedSeconds)s")
    }
}
