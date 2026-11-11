// Ported from CrazyBrag/model/PlayerHand.swift
import { HandResolver } from './handResolver.js';

export class PlayerHand {
    constructor(hand = []) {
        this.hand = [...hand];
    }

    get score() {
        return new HandResolver(this.hand).createScore();
    }

    receive(card) {
        this.hand.push(card);
    }

    display() {
        return this.hand.map(card => card.display()).join('_');
    }

    /** Empties the hand and returns the cards that were in it */
    stash() {
        const stash = this.hand;
        this.hand = [];
        return stash;
    }

    replace(cardInHand, withCard) {
        const index = this.hand.indexOf(cardInHand);
        if (index !== -1) {
            this.hand[index] = withCard;
        }
    }

    play(turn, middle) {
        if (turn.kind === 'swap') {
            this.replace(turn.hand, turn.middle);
            middle.replace(turn.middle, turn.hand);
        } else {
            const tmp = this.hand;
            this.hand = middle.hand;
            middle.hand = tmp;
            //First card is down
            const [down] = middle.hand.splice(turn.downIndex, 1);
            middle.hand.unshift(down);
        }
    }

    /** -1 if the card is not in the hand */
    indexOf(card) {
        return this.hand.indexOf(card);
    }
}
