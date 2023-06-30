//
//  ExampleHands.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 26/09/2022.
//

import Foundation
@testable import CrazyBrag

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

