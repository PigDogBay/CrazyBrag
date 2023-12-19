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
    let type : BragHandTypes
    
    private static let flattened = [
        "2s,3h,5d,5 Stinking High,high",
        "7h,tc,jd,Jack High,high",
        "2d,qh,ks,King High,high",
        "2s,4h,Ah,Ace High,high",
        "jc,kd,As,Ace High,high",
        "2c,2d,jh,Dogs,pair",
        "3c,3h,2h,Pair of Threes,pair",
        "ts,th,4c,Blankets,pair",
        "kh,Ks,jd,Pair of Kings,pair",
        "Ah,Ad,ks,Bullets,pair",
        "jd,kd,ad,Ace Flush,flush",
        "2d,3d,5d,5 Flush,flush",
        "3h,5h,9h,9 Flush,flush",
        "6c,7c,jc,Jack Flush,flush",
        "4s,8s,ks,King Flush,flush",
        "2d,3d,4s,2-3-4,run",
        "3s,4s,5d,3-4-5 Beehive,run",
        "4c,5d,6h,4-5-6 Weetabix,run",
        "4c,5d,6h,4-5-6 Tom Mix,run",
        "7h,8d,9h,7-8-9 Woodbine,run",
        "9h,tc,jd,9-10-Jack Burt Bacharach,run",
        "th,js,qc,10-Joe-Green,run",
        "jh,qd,kc,Jack-Queen-King,run",
        "qd,kc,ah,Acker-Boo,run",
        "as,2d,3c,Up a Tree,run",
        "2s,3s,4s,2-3-4 Trotting,trotter",
        "7c,8c,9c,7-8-9 Trotter,trotter",
        "th,jh,qh,10-Jack-Queen Trotter,trotter",
        "qd,kd,ad,Acker Trotter,trotter",
        "as,2s,3s,1-2-3 Trotter,trotter",
        "2c,2h,2s,Prial of Dogs,prial",
        "tc,th,td,Prial of Blankets,prial",
        "kh,ks,kd,Prial of Kings,prial",
        "as,ad,ah,Prial of Bullets,prial",
        "3c,3d,3s,Yippee Ki-Yay,prial",
    ]
    
    static func unflatten(flattened : String) -> ExampleHand?{
        let parts = flattened.split(separator: ",").map{String($0)}
        guard parts.count == 5,
              let card1 = PlayingCard.unflatten(flattened: parts[0]),
              let card2 = PlayingCard.unflatten(flattened: parts[1]),
              let card3 = PlayingCard.unflatten(flattened: parts[2]),
              let bragType = BragHandTypes.unflatten(flattened: parts[4])
        else {
            return nil
        }
        return ExampleHand(hand: [card1,card2,card3], name: parts[3], type: bragType)
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
