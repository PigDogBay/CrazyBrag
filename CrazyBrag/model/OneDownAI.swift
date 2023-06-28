//
//  OneDownAI.swift
//  CardGames
//
//  Created by Mark Bailey on 06/10/2022.
//

import Foundation
class OneDownAI : AI {
    weak var player: Player?

    func play(middle: PlayerHand) -> Turn {
        return HandGenerator(playerHand: player!.hand)
            .generatePossibleTurnsFaceUpOnly(middle: middle)
            .max(by: {$0.score < $1.score})!
            .turn
    }
}

class ChancerAI : AI {
    weak var player: Player?

    func play(middle: PlayerHand) -> Turn {
        let generator = HandGenerator(playerHand: player!.hand)
        let scoredTurn = generator
            .generatePossibleTurnsFaceUpOnly(middle: middle)
            .max(by: {$0.score < $1.score})!

        //Testing found that it is best to try for the middle
        //when you have less than a pair of 2's
        if scoredTurn.score.type == .high {
            let potentialTurn = generator
                .generatePotentialHands(middle: middle)
                .max(by: {$0.score < $1.score})!
            
            if potentialTurn.score.type >= BragHandTypes.flush {
                return potentialTurn.turn
            }
        }
        return scoredTurn.turn
    }
}
