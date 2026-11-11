// Ported from CrazyBrag/model/Defines.swift

export class CardAlreadyInThePackError extends Error {
    constructor(card) {
        super(`Card already in the pack ${card.display()}`);
        this.card = card;
    }
}

/** The types of hand, the values are in order so they can be compared */
export const BragHandTypes = Object.freeze({
    high: 0, pair: 1, flush: 2, run: 3, trotter: 4, prial: 5,

    display(type) {
        return ['High', 'Pair', 'Flush', 'Run', 'Trotter', 'Prial'][type];
    },
});

/** Compare two of these by their score */
export class BragHandScore {
    constructor(type, score) {
        this.type = type;
        this.score = score;
        Object.freeze(this);
    }

    display() {
        return `${BragHandTypes.display(this.type)} ${this.score}`;
    }
}

/** Player can swap one card with the middle or all 3 */
export const Turn = Object.freeze({
    swap(hand, middle) {
        return Object.freeze({ kind: 'swap', hand, middle });
    },

    /** downIndex: the index of the card in the player's hand that goes face down in the middle */
    all(downIndex = -1) {
        return Object.freeze({ kind: 'all', downIndex });
    },

    equals(a, b) {
        return a.kind === b.kind && a.hand === b.hand && a.middle === b.middle && a.downIndex === b.downIndex;
    },

    display(turn) {
        return turn.kind === 'swap' ? `Swap ${turn.hand.display()} for ${turn.middle.display()}` : 'All';
    },
});

/** Looky Looky rules: before making their move a player may take up to two of these three actions */
export const TurnAction = Object.freeze({
    /** Look at the face down card in the middle, it is not shown to the other players */
    looky: 'looky',
    /** Discard the whole hand and be dealt three new cards */
    stashHand: 'stashHand',
    /** Discard one card of the middle, which is replaced with a new card */
    changeMiddle: 'changeMiddle',
    allCases: Object.freeze(['looky', 'stashHand', 'changeMiddle']),
});

/** The action a computer player has decided to take: {action} and, for changeMiddle, {card} */
export const ActionChoice = Object.freeze({
    looky: Object.freeze({ action: TurnAction.looky }),
    stashHand: Object.freeze({ action: TurnAction.stashHand }),
    changeMiddle(card) {
        return Object.freeze({ action: TurnAction.changeMiddle, card });
    },
});

/** What happened when a TurnAction was taken, for the view to show */
export const TurnActionResult = Object.freeze({
    looky(card) {
        return Object.freeze({ action: TurnAction.looky, card });
    },
    /** discarded: the cards thrown in, dealt: the DealtCards that replaced them */
    stashHand(discarded, dealt) {
        return Object.freeze({ action: TurnAction.stashHand, discarded, dealt });
    },
    /** discarded: the card taken out of the middle, dealt: the DealtCard that replaced it */
    changeMiddle(discarded, dealt) {
        return Object.freeze({ action: TurnAction.changeMiddle, discarded, dealt });
    },
});

export class ScoredTurn {
    constructor(turn, score, middleScore) {
        this.turn = turn;
        this.score = score;
        this.middleScore = middleScore;
    }

    display() {
        return `${Turn.display(this.turn)} score: ${this.score.display()}, middle: ${this.middleScore.display()}`;
    }
}

/** A card and where it is on the table. Seat -1 is the middle, 0 the human, 1... the computer players */
export class DealtCard {
    /** cardCount: 1 = first card, 2 = second card or 3 = last card dealt to the player or middle */
    constructor(seat, card, cardCount) {
        this.seat = seat;
        this.card = card;
        this.cardCount = cardCount;
        Object.freeze(this);
    }

    static toPlayer(seat, card, cardCount) {
        return new DealtCard(seat, card, cardCount);
    }

    static toMiddle(card, cardCount) {
        return new DealtCard(-1, card, cardCount);
    }

    get isMiddle() {
        return this.seat < 0;
    }
}

/** The first of the largest elements, as Swift's max(by:). score: element -> number */
export function maxBy(items, score) {
    let best;
    let bestScore;
    for (const item of items) {
        const itemScore = score(item);
        if (best === undefined || itemScore > bestScore) {
            best = item;
            bestScore = itemScore;
        }
    }
    return best;
}

/** The first of the smallest elements, as Swift's min(by:). score: element -> number */
export function minBy(items, score) {
    return maxBy(items, item => -score(item));
}

/** A shuffled copy of the array */
export function shuffled(items) {
    const copy = [...items];
    for (let i = copy.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [copy[i], copy[j]] = [copy[j], copy[i]];
    }
    return copy;
}

export function randomElement(items) {
    return items[Math.floor(Math.random() * items.length)];
}
