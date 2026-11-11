// Ported from CrazyBrag/model/Player.swift
import { PlayerHand } from './playerHand.js';
import { BragHandScore, BragHandTypes } from './defines.js';

/** Each player must have a unique seat */
export class Player {
    constructor(name, ai) {
        this.name = name;
        this.hand = new PlayerHand();
        this.lives = 3;
        /** Looky Looky rules: true once the player has been given the extra life for their first winning prial */
        this.hasHadExtraLife = false;
        this.score = new BragHandScore(BragHandTypes.high, 0);
        this.seat = 0;
        this.ai = ai;
        this.gamesWon = 0;
        ai.player = this;
    }

    play(middle) {
        const turn = this.ai.play(middle);
        this.hand.play(turn, middle);
        return turn;
    }

    resolveHand() {
        this.score = this.hand.score;
    }
}
