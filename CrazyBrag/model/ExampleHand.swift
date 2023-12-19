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
        "jd,kd,ad,Ace Flush",
        "2d,3d,5d,5 Flush",
        "3h,5h,9h,9 Flush",
        "6c,7c,jc,Jack Flush",
        "4s,8s,ks,King Flush",
        "2d,3d,4s,2-3-4",
        "3s,4s,5d,3-4-5 Beehive",
        "4c,5d,6h,4-5-6 Weetabix",
        "4c,5d,6h,4-5-6 Tom Mix",
        "7h,8d,9h,7-8-9 Woodbine",
        "9h,tc,jd,9-10-Jack Burt Bacharach",
        "th,js,qc,10-Joe-Green",
        "jh,qd,kc,Jack-Queen-King",
        "qd,kc,ah,Acker-Boo",
        "as,2d,3c,Up a Tree",
        "2s,3s,4s,2-3-4 Trotting",
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

let PrialOfAces = [PlayingCard(suit: .clubs, rank: .ace),
            PlayingCard(suit: .hearts, rank: .ace),
            PlayingCard(suit: .spades, rank: .ace)]
let PrialOfKings = [PlayingCard(suit: .diamonds, rank: .king),
            PlayingCard(suit: .hearts, rank: .king),
            PlayingCard(suit: .spades, rank: .king)]
let PrialOfThrees = [PlayingCard(suit: .clubs, rank: .three),
            PlayingCard(suit: .diamonds, rank: .three),
            PlayingCard(suit: .spades, rank: .three)]
let PrialOfFours = [PlayingCard(suit: .clubs, rank: .four),
            PlayingCard(suit: .diamonds, rank: .four),
            PlayingCard(suit: .spades, rank: .four)]
let StateExpress = [PlayingCard(suit: .clubs, rank: .five),
            PlayingCard(suit: .diamonds, rank: .five),
            PlayingCard(suit: .spades, rank: .five)]

let JQKTrotter = [PlayingCard(suit: .spades, rank: .queen),
            PlayingCard(suit: .spades, rank: .jack),
            PlayingCard(suit: .spades, rank: .king)]
let A23Trotter = [PlayingCard(suit: .diamonds, rank: .two),
            PlayingCard(suit: .diamonds, rank: .ace),
            PlayingCard(suit: .diamonds, rank: .three)]

let JQKRun = [PlayingCard(suit: .clubs, rank: .queen),
            PlayingCard(suit: .diamonds, rank: .jack),
            PlayingCard(suit: .diamonds, rank: .king)]
let A23Run = [PlayingCard(suit: .clubs, rank: .two),
            PlayingCard(suit: .diamonds, rank: .three),
            PlayingCard(suit: .diamonds, rank: .ace)]
let AKQRun = [PlayingCard(suit: .clubs, rank: .king),
            PlayingCard(suit: .diamonds, rank: .ace),
            PlayingCard(suit: .diamonds, rank: .queen)]
let Weetabix456Run = [PlayingCard(suit: .clubs, rank: .five),
            PlayingCard(suit: .spades, rank: .six),
            PlayingCard(suit: .hearts, rank: .four)]
let Beehive345Run = [PlayingCard(suit: .clubs, rank: .five),
            PlayingCard(suit: .spades, rank: .three),
            PlayingCard(suit: .hearts, rank: .four)]
let Beehive345Run2 = [PlayingCard(suit: .spades, rank: .five),
            PlayingCard(suit: .hearts, rank: .three),
            PlayingCard(suit: .clubs, rank: .four)]

let AKJFlush = [PlayingCard(suit: .diamonds, rank: .ace),
            PlayingCard(suit: .diamonds, rank: .jack),
            PlayingCard(suit: .diamonds, rank: .king)]
let KJTFlush = [PlayingCard(suit: .diamonds, rank: .ten),
            PlayingCard(suit: .diamonds, rank: .jack),
            PlayingCard(suit: .diamonds, rank: .king)]
let KQTFlush = [PlayingCard(suit: .hearts, rank: .ten),
            PlayingCard(suit: .hearts, rank: .queen),
            PlayingCard(suit: .hearts, rank: .king)]
let KJ9Flush = [PlayingCard(suit: .spades, rank: .nine),
            PlayingCard(suit: .spades, rank: .jack),
            PlayingCard(suit: .spades, rank: .king)]

let QQKPair = [PlayingCard(suit: .clubs, rank: .queen),
            PlayingCard(suit: .spades, rank: .queen),
            PlayingCard(suit: .diamonds, rank: .king)]
let QQAPair = [PlayingCard(suit: .clubs, rank: .queen),
            PlayingCard(suit: .diamonds, rank: .queen),
            PlayingCard(suit: .diamonds, rank: .ace)]
let AAQPair = [PlayingCard(suit: .clubs, rank: .ace),
            PlayingCard(suit: .diamonds, rank: .queen),
            PlayingCard(suit: .diamonds, rank: .ace)]

let KQ2High = [PlayingCard(suit: .clubs, rank: .queen),
            PlayingCard(suit: .diamonds, rank: .two),
            PlayingCard(suit: .diamonds, rank: .king)]
let KQ3High = [PlayingCard(suit: .clubs, rank: .queen),
            PlayingCard(suit: .hearts, rank: .three),
            PlayingCard(suit: .diamonds, rank: .king)]
let A42High = [PlayingCard(suit: .clubs, rank: .two),
            PlayingCard(suit: .diamonds, rank: .ace),
            PlayingCard(suit: .diamonds, rank: .four)]
