//
//  PossibleHandResolver.swift
//  CardGames
//
//  Created by Mark Bailey on 06/10/2022.
//

import Foundation

///Handles the case when
///2 cards up, 1 card down
struct PossibleHandResolver {
    let hand : [PlayingCard]
    let scoreSortedHand : [PlayingCard]
    init(hand : [PlayingCard]){
        self.hand = hand.sorted{$0.rank.rawValue < $1.rank.rawValue}
        self.scoreSortedHand = hand.sorted{$0.rank.score() < $1.rank.score()}
    }
    
    func createScore() -> BragHandScore{
        let type = resolveHandType()
        let score = calculateScore(type: type)
        return BragHandScore(type: type, score: score)
    }
    
    private var isPossibleFlush : Bool {
        return hand[0].suit == hand[1].suit
    }
    private var isPossibleRun : Bool {
        //Check for AKQ
        if hand[0].rank == .ace && (hand[1].rank == .queen || hand[1].rank == .king) {
            return true
        }
        let diff = hand[1].rank.rawValue - hand[0].rank.rawValue
        return diff == 1 || diff == 2
    }

    private func resolveHandType() -> BragHandTypes {
        if hand[0].rank==hand[1].rank {
            return .prial
        }
        if isPossibleRun && isPossibleFlush {
            return .trotter
        }
        if isPossibleRun {
            return .run
        }
        if isPossibleFlush {
            return .flush
        }
        return .high
    }
    
    private func calculateScore(type : BragHandTypes) -> Int {
        switch type {
        case .high:
            return 0x00000000 + cardRankScore
        case .flush:
            return 0x02000000 + cardRankScore
        case .run:
            return 0x03000000 + cardRankScore
        case .trotter:
            return 0x04000000 + cardRankScore
        case .pair:
            fallthrough
        case .prial:
            //Score pair of threes low, as probably just a pair
            return 0x05000000 + hand[0].rank.score()
        }
    }
    ///0x00[Highest][Lowest]
    ///For possible runs, score AKQ higher than A23, as high hands (most likely) AKx or AQx are higher than A2x or A3x
    private var cardRankScore : Int {
        scoreSortedHand[0].rank.score() + scoreSortedHand[1].rank.score()<<8
    }
}
