// Ported from CrazyBrag/model/Deck.swift
import { PlayingCard } from './playingCard.js';
import { CardAlreadyInThePackError, shuffled } from './defines.js';

export class Deck {
    constructor() {
        this.deck = [];
        /** Looky Looky rules: the good and bad jokers are added to the pack */
        this.hasJokers = false;
    }

    /** The number of cards in a full pack, which depends on the rule set */
    get max() {
        return this.hasJokers ? 54 : 52;
    }

    get count() {
        return this.deck.length;
    }

    createDeck() {
        this.deck = [...PlayingCard.standardPack];
        if (this.hasJokers) {
            this.deck.push(PlayingCard.goodJoker, PlayingCard.badJoker);
        }
    }

    shuffle() {
        this.deck = shuffled(this.deck);
    }

    deal() {
        return this.deck.shift();
    }

    /** Cards go on the bottom of the deck. Throws CardAlreadyInThePackError for a duplicate */
    receive(cards) {
        for (const card of cards) {
            if (this.deck.includes(card)) {
                throw new CardAlreadyInThePackError(card);
            }
            this.deck.push(card);
        }
    }

    /** Reduce the deck size to the numberOfCards */
    cut(numberOfCards) {
        if (this.count > numberOfCards) {
            this.deck.length = numberOfCards;
        }
    }

    remove(card) {
        this.deck = this.deck.filter(other => other !== card);
    }
}
