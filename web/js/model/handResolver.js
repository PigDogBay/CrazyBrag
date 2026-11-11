// Ported from CrazyBrag/model/HandResolver.swift
import { PlayingCard, Rank } from './playingCard.js';
import { BragHandScore, BragHandTypes } from './defines.js';

/**
 * Scores a three card hand.
 * The good joker is wild: it is played as whichever card makes the best hand, so hand and scoreSortedHand
 * hold that card in place of the joker. Likewise a two when deuces are wild, which may change its suit.
 * The bad joker is never part of a pair, flush, run or prial.
 */
export class HandResolver {
    /** natural: score the cards as they are, the wild cards are not played as other cards */
    constructor(hand, natural = false) {
        const played = natural ? hand : PlayingCard.playWildCards(hand, h => new HandResolver(h, true).createScore());
        this.hand = [...played].sort((a, b) => a.rank - b.rank);
        this.scoreSortedHand = [...played].sort((a, b) => Rank.score(a.rank) - Rank.score(b.rank));
    }

    get highestCard() {
        return this.scoreSortedHand[2];
    }

    createScore() {
        const type = this.resolveHandType();
        return new BragHandScore(type, this.calculateScore(type));
    }

    get pairRank() {
        return this.hand[1].rank;
    }

    get isPrial() {
        return this.hand[0].rank === this.hand[1].rank && this.hand[1].rank === this.hand[2].rank;
    }

    get isFlush() {
        return this.hand[0].suit === this.hand[1].suit && this.hand[1].suit === this.hand[2].suit;
    }

    get isAKQ() {
        return this.hand[0].rank === Rank.ace && this.hand[1].rank === Rank.queen && this.hand[2].rank === Rank.king;
    }

    get isA23() {
        return this.hand[0].rank === Rank.ace && this.hand[1].rank === Rank.two && this.hand[2].rank === Rank.three;
    }

    get hasJoker() {
        return this.hand.some(card => card.isJoker);
    }

    get isRun() {
        //A joker left in the hand (the bad joker) is not part of a run,
        //nor of a pair, flush or prial as nothing else shares its rank or suit
        if (this.hasJoker) {
            return false;
        }
        if (this.isAKQ) {
            return true;
        }
        const rank1 = this.hand[0].rank + 2;
        const rank2 = this.hand[1].rank + 1;
        const rank3 = this.hand[2].rank;
        return rank1 === rank2 && rank2 === rank3;
    }

    get isPair() {
        const [a, b, c] = this.hand;
        return a.rank === b.rank || b.rank === c.rank || a.rank === c.rank;
    }

    resolveHandType() {
        if (this.isPrial) {
            return BragHandTypes.prial;
        }
        if (this.isRun && this.isFlush) {
            return BragHandTypes.trotter;
        }
        if (this.isRun) {
            return BragHandTypes.run;
        }
        if (this.isFlush) {
            return BragHandTypes.flush;
        }
        if (this.isPair) {
            return BragHandTypes.pair;
        }
        return BragHandTypes.high;
    }

    calculateScore(type) {
        switch (type) {
            case BragHandTypes.pair:
                return 0x01000000 + this.scorePair();
            case BragHandTypes.flush:
                return 0x02000000 + this.cardRankScore;
            case BragHandTypes.run:
                return 0x03000000 + this.scoreRun;
            case BragHandTypes.trotter:
                return 0x04000000 + this.scoreRun;
            case BragHandTypes.prial:
                return 0x05000000 + this.scorePrial();
            default:
                return this.cardRankScore;
        }
    }

    /** 0x00[High][Middle][Lowest] */
    get cardRankScore() {
        const [low, middle, high] = this.scoreSortedHand.map(card => Rank.score(card.rank));
        return low + (middle << 8) + (high << 16);
    }

    /** A23, AKQ, then highest scoring card */
    get scoreRun() {
        if (this.isA23) {
            return 0xff;
        }
        return Rank.score(this.scoreSortedHand[2].rank);
    }

    /** 333, AAA ... highest scoring card */
    scorePrial() {
        if (this.hand[0].rank === Rank.three) {
            return 0x05ffffff;
        }
        return Rank.score(this.highestCard.rank);
    }

    scorePair() {
        //In a sorted hand the middle card is part of the pair
        const pairScore = Rank.score(this.hand[1].rank);
        //First or Last card is the high, add both together
        const highScore = Rank.score(this.hand[0].rank) + Rank.score(this.hand[2].rank);
        return (pairScore << 16) + highScore;
    }

    static removeHighScoreFromPair(score) {
        return score & 0xffffff00;
    }
}
