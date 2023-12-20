//
//  HandResolver.swift
//  CardGames
//
//  Created by Mark Bailey on 10/09/2022.
//

import Foundation

struct HandResolver {
    let hand : [PlayingCard]
    let scoreSortedHand : [PlayingCard]
    
    var highestCard : PlayingCard {
        scoreSortedHand[2]
    }

    init(hand : [PlayingCard]){
        self.hand = hand.sorted{$0.rank.rawValue < $1.rank.rawValue}
        self.scoreSortedHand = hand.sorted{$0.rank.score() < $1.rank.score()}
    }
    
    func createScore() -> BragHandScore{
        let type = resolveHandType()
        let score = calculateScore(type: type)
        return BragHandScore(type: type, score: score)
    }
    
    var pairRank : Rank {return hand[1].rank}
    
    private var isPrial : Bool {
        return hand[0].rank==hand[1].rank && hand[1].rank==hand[2].rank
    }
    private var isFlush : Bool {
        return hand[0].suit == hand[1].suit && hand[1].suit == hand[2].suit
    }
    private var isAKQ : Bool {
        return hand[0].rank == .ace && hand[1].rank == .queen && hand[2].rank == .king
    }
    private var isA23 : Bool {
        return hand[0].rank == .ace && hand[1].rank == .two && hand[2].rank == .three
    }

    private var isRun : Bool {
        if isAKQ {
            return true
        }
        let rank1 = hand[0].rank.rawValue + 2
        let rank2 = hand[1].rank.rawValue + 1
        let rank3 = hand[2].rank.rawValue
        return  rank1 == rank2 && rank2 == rank3
    }
    private var isPair : Bool {
        return hand[0].rank==hand[1].rank || hand[1].rank==hand[2].rank || hand[0].rank==hand[2].rank
    }

    private func resolveHandType() -> BragHandTypes {
        if isPrial {
            return .prial
        }
        if isRun && isFlush {
            return .trotter
        }
        if isRun {
            return .run
        }
        if isFlush {
            return .flush
        }
        if isPair {
            return .pair
        }
        return .high
    }
    
    private func calculateScore(type : BragHandTypes) -> Int {
        switch type {
        case .high:
            return 0x00000000 + cardRankScore
        case .pair:
            return 0x01000000 + scorePair()
        case .flush:
            return 0x02000000 + cardRankScore
        case .run:
            return 0x03000000 + scoreRun
        case .trotter:
            return 0x04000000 + scoreRun
        case .prial:
            return 0x05000000 + scorePrial()
        }
    }
    ///0x00[High][Middle][Lowest]
    private var cardRankScore : Int {
        return scoreSortedHand[0].rank.score()  +
        scoreSortedHand[1].rank.score()<<8 +
        scoreSortedHand[2].rank.score()<<16
    }
    ///A23, AKQ, then highest scoring card
    private var scoreRun : Int {
        if isA23 {
            return 0xff
        }
        return scoreSortedHand[2].rank.score()
    }
    ///333, AAA ... highest scoring card
    private func scorePrial() -> Int {
        if hand[0].rank == .three{
            return 0x05ffffff
        }
        return highestCard.rank.score()
    }
    private func scorePair() -> Int {
        //In a sorted hand the middle card is part of the pair
        let pairScore = hand[1].rank.score()
        //First or Last card is the high, add both together
        let highScore = hand[0].rank.score() + hand[2].rank.score()
        return pairScore<<16 + highScore
    }
    
    static func removeHighScoreFromPair(score : Int) -> Int {
        return score & 0xffffff00
    }
}
