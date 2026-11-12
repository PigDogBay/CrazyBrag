// Ported from CrazyBrag/StartPresenter.swift
import { Deck } from '../model/deck.js';
import { ExampleHand } from '../model/exampleHand.js';
import { Layer, StartLayout } from './layout.js';

/**
 * The start screen's demonstration: deals each example hand from the deck, turns it over, spreads it out
 * and names it, then gathers it back in, for ever.
 *
 * Each step is an animation of the view, which calls the completion when it has finished. The view implements:
 *   setZ(card, z)
 *   actionMove(card, pos, duration, completion)
 *   actionTurnCard(card, duration, completion)        turn the card face up after the duration
 *   actionSpread(hand, byX, completion)               fan out the three cards
 *   actionWait(duration, completion)
 *   actionGather(card, pos, duration, completion)     turn the card face down and straight, and move it
 *   actionFadeInName(name, duration), actionFadeOutName(duration)
 */
export class StartPresenter {
    constructor(isPhone) {
        this.deck = new Deck();
        this.deck.createDeck();
        this.startLayout = new StartLayout(isPhone);
        this.view = null;
        this.state = 'deal';
        this.exampleIndex = 0;
        this.examples = ExampleHand.examples();
    }

    get hand() {
        return this.examples[this.exampleIndex].hand;
    }

    deal(index) {
        if (index === 3) {
            this.state = 'show';
            this.next();
            return;
        }
        this.view?.setZ(this.hand[index], Layer.card1 + index);
        this.view?.actionMove(this.hand[index], this.startLayout.cardPosition(index), 0.25, () => this.deal(index + 1));
    }

    turn(index) {
        if (index === 3) {
            this.state = 'spread';
            this.next();
        } else {
            this.view?.actionTurnCard(this.hand[index], 0.1, () => this.turn(index + 1));
        }
    }

    gather(index) {
        if (index === 3) {
            this.state = 'next';
            this.next();
        } else {
            this.view?.actionGather(this.hand[index], this.startLayout.deckPos, 0.1, () => this.gather(index + 1));
        }
    }

    /** Starts the demonstration, and then carries out each step in turn */
    next() {
        switch (this.state) {
            case 'deal':
                this.deal(0);
                break;
            case 'show':
                this.turn(0);
                break;
            case 'spread':
                this.view?.actionSpread(this.hand, this.startLayout.spreadOffset, () => {
                    this.state = 'wait';
                    this.next();
                });
                break;
            case 'wait':
                this.view?.actionFadeInName(this.examples[this.exampleIndex].name, 2.0);
                this.view?.actionWait(3.0, () => {
                    this.state = 'gather';
                    this.next();
                    this.view?.actionFadeOutName(0.5);
                });
                break;
            case 'gather':
                this.gather(0);
                break;
            case 'next':
                this.exampleIndex = (this.exampleIndex + 1) % this.examples.length;
                this.state = 'deal';
                this.next();
                break;
        }
    }
}
