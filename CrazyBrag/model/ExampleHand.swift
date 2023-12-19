//
//  ExampleHand.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 18/12/2023.
//

import Foundation

struct ExampleHand {
    
    let hand : [PlayingCard]
    let name : String
    
    private static let flattened = [
        "2s,3h,5d,5 Stinking High",
        "7h,tc,jd,Jack High",
        "2d,qh,ks,King High",
        "2s,4h,Ah,Ace High",
        "jc,kd,As,Ace High",
        "2c,2d,jh,Dogs",
        "3c,3h,2h,Pair of Threes",
        "ts,th,4c,Blankets",
        "kh,Ks,jd,Pair of Kings",
        "Ah,Ad,ks,Bullets",
        "2d,3d,5d,5 Flush",
        "3h,5h,9h,9 Flush",
        "6c,7c,jc,Jack Flush",
        "4s,8s,ks,King Flush",
        "jd,kd,ad,Ace Flush",
        "2d,3d,4s,2-3-4",
        "3s,4s,5d,3-4-5 Beehive",
        "4c,5d,6h,4-5-6 Tom Mix",
        "7h,8d,9h,7-8-9 Woodbine",
        "9h,tc,jd,9-10-Jack Burt Bacharach",
        "th,js,qc,10-Joe-Green",
        "jh,qd,kc,Jack-Queen-King",
        "qd,kc,ah,Acker-Boo",
        "as,2d,3c,Up a Tree",
        "2s,3s,4s,2-3-4 Trotter",
        "7c,8c,9c,7-8-9 Trotter",
        "th,jh,qh,10-Jack-Queen Trotter",
        "qd,kd,ad,Acker Trotter",
        "as,2s,3s,1-2-3 Trotter",
        "2c,2h,2s,Prial of Dogs",
        "tc,th,td,Prial of Blankets",
        "kh,ks,kd,Prial of Kings",
        "as,ad,ah,Prial of Bullets",
        "3c,3d,3s,Yippee Ki-Yay",
    ]
    
    static func unflatten(flattened : String) -> ExampleHand?{
        let parts = flattened.split(separator: ",").map{String($0)}
        guard parts.count == 4,
              let card1 = PlayingCard.unflatten(flattened: parts[0]),
              let card2 = PlayingCard.unflatten(flattened: parts[1]),
              let card3 = PlayingCard.unflatten(flattened: parts[2])
        else {
            return nil
        }
        return ExampleHand(hand: [card1,card2,card3], name: parts[3])
    }
    
    static func examples() -> [ExampleHand]{
        return flattened.compactMap{unflatten(flattened: $0)}
    }
}
