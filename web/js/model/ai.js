// Ported from CrazyBrag/model/AI.swift
import { HandGenerator } from './handGenerator.js';
import { PlayerHand } from './playerHand.js';
import { BragHandTypes, maxBy, randomElement } from './defines.js';
import { PlayingCard, Rank, Suit } from './playingCard.js';

/** Decides a player's move. The Player sets itself as ai.player */
export class AI {
    constructor() {
        this.player = null;
    }

    /** Returns the Turn to play */
    play(middle) {
        throw new Error('play(middle) not implemented');
    }

    /**
     * Looky Looky rules: asked before play(middle), and again after each action is taken, until it returns null.
     * available: the actions the player is still allowed to take this turn. By default take no actions
     */
    chooseAction(middle, available) {
        return null;
    }

    /** Looky Looky rules: the player has taken the looky action and this is the face down middle card */
    lookedAt(card) {}
}

/** The human player: the turn is filled in by the presenter before the model asks for it */
export class HumanAI extends AI {
    constructor() {
        super();
        this.turn = null;
    }

    play(middle) {
        return this.turn;
    }
}

export class RandomAI extends AI {
    play(middle) {
        return randomElement(new HandGenerator(this.player.hand).generatePossibleTurns(middle)).turn;
    }
}

export class BestAI extends AI {
    play(middle) {
        return maxBy(new HandGenerator(this.player.hand).generatePossibleTurns(middle), turn => turn.score.score).turn;
    }
}

export class PrialChuckerAI extends AI {
    constructor(school) {
        super();
        this.school = school;
        const lowHand = [PlayingCard.of(Suit.clubs, Rank.two), PlayingCard.of(Suit.diamonds, Rank.eight), PlayingCard.of(Suit.hearts, Rank.eight)];
        this.lowestScoreToConsiderPrial = new PlayerHand(lowHand).score.score;
    }

    bestTurn(middle) {
        return maxBy(new HandGenerator(this.player.hand).generatePossibleTurns(middle), turn => turn.score.score);
    }

    play(middle) {
        const best = this.bestTurn(middle);
        const prialInMiddle = new HandGenerator(this.player.hand).generatePossibleTurns(middle)
            .find(turn => turn.middleScore.type === BragHandTypes.prial);
        if (prialInMiddle && this.school.players.length > 2 && best.score.score < this.lowestScoreToConsiderPrial) {
            return prialInMiddle.turn;
        }
        return best.turn;
    }
}
