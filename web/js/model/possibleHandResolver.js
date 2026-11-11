// Ported from CrazyBrag/model/PossibleHandResolver.swift
import { PlayingCard, Rank } from './playingCard.js';
import { BragHandScore, BragHandTypes } from './defines.js';

/**
 * Handles the case when 2 cards are up and 1 card is down: what could these two cards become?
 * The good joker is wild, it is played as the card that gives the best possible hand,
 * as is a two when deuces are wild
 */
export class PossibleHandResolver {
    /** natural: score the cards as they are, the wild cards are not played as other cards */
    constructor(hand, natural = false) {
        const played = natural ? hand : PlayingCard.playWildCards(hand, h => new PossibleHandResolver(h, true).createScore());
        this.hand = [...played].sort((a, b) => a.rank - b.rank);
        this.scoreSortedHand = [...played].sort((a, b) => Rank.score(a.rank) - Rank.score(b.rank));
    }

    createScore() {
        const type = this.resolveHandType();
        return new BragHandScore(type, this.calculateScore(type));
    }

    get isPossibleFlush() {
        return this.hand[0].suit === this.hand[1].suit;
    }

    get isPossibleRun() {
        //Check for AKQ
        if (this.hand[0].rank === Rank.ace && (this.hand[1].rank === Rank.queen || this.hand[1].rank === Rank.king)) {
            return true;
        }
        const diff = this.hand[1].rank - this.hand[0].rank;
        return diff === 1 || diff === 2;
    }

    resolveHandType() {
        //A joker left in the hand (the bad joker) cannot be part of a prial, run or flush
        if (this.hand.some(card => card.isJoker)) {
            return BragHandTypes.high;
        }
        if (this.hand[0].rank === this.hand[1].rank) {
            return BragHandTypes.prial;
        }
        if (this.isPossibleRun && this.isPossibleFlush) {
            return BragHandTypes.trotter;
        }
        if (this.isPossibleRun) {
            return BragHandTypes.run;
        }
        if (this.isPossibleFlush) {
            return BragHandTypes.flush;
        }
        return BragHandTypes.high;
    }

    calculateScore(type) {
        switch (type) {
            case BragHandTypes.flush:
                return 0x02000000 + this.cardRankScore;
            case BragHandTypes.run:
                return 0x03000000 + this.cardRankScore;
            case BragHandTypes.trotter:
                return 0x04000000 + this.cardRankScore;
            case BragHandTypes.pair:
            case BragHandTypes.prial:
                //Score pair of threes low, as probably just a pair
                return 0x05000000 + Rank.score(this.hand[0].rank);
            default:
                return this.cardRankScore;
        }
    }

    /**
     * 0x00[Highest][Lowest]
     * For possible runs, score AKQ higher than A23, as high hands (most likely) AKx or AQx are higher than A2x or A3x
     */
    get cardRankScore() {
        return Rank.score(this.scoreSortedHand[0].rank) + (Rank.score(this.scoreSortedHand[1].rank) << 8);
    }
}
