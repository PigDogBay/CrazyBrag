// Ported from CrazyBrag/model/PlayingCard.swift

export const Suit = Object.freeze({
    clubs: 0, diamonds: 1, hearts: 2, spades: 3,
    /** The jokers are not in any of the four suits */
    joker: 4,
    /** The four suits of a standard pack */
    standard: Object.freeze([0, 1, 2, 3]),

    display(suit) {
        return ['♣️', '♦️', '❤️', '♠️', '🃏'][suit];
    },

    unflatten(flattened) {
        switch (flattened.toLowerCase()) {
            case 'h': return Suit.hearts;
            case 'c': return Suit.clubs;
            case 'd': return Suit.diamonds;
            case 's': return Suit.spades;
            default: return null;
        }
    },
});

export const Rank = Object.freeze({
    ace: 0, two: 1, three: 2, four: 3, five: 4, six: 5, seven: 6, eight: 7, nine: 8, ten: 9, jack: 10, queen: 11, king: 12,
    /** The jokers, kept after the thirteen standard ranks */
    goodJoker: 13, badJoker: 14,
    /** The thirteen ranks of a standard pack */
    standard: Object.freeze([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]),

    isJoker(rank) {
        return rank === Rank.goodJoker || rank === Rank.badJoker;
    },

    display(rank) {
        return ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'Good', 'Bad'][rank];
    },

    /** Ace high. A joker counts for nothing, lower than a two */
    score(rank) {
        if (Rank.isJoker(rank)) {
            return 0;
        }
        return rank === Rank.ace ? 14 : rank + 1;
    },

    unflatten(flattened) {
        const index = ['a', '2', '3', '4', '5', '6', '7', '8', '9', 't', 'j', 'q', 'k'].indexOf(flattened.toLowerCase());
        return index === -1 ? null : index;
    },
});

/** Rules that change how hands are scored, set by the Model at the start of each game */
export const HandRules = {
    /** Looky Looky: a two can be played as the two of any suit, it is always a two */
    deucesWild: false,
};

const cards = new Map();

/**
 * A playing card. There is only ever one object for each card, get it with PlayingCard.of(),
 * so cards can be compared with === and found with includes() and indexOf().
 */
export class PlayingCard {
    constructor(suit, rank) {
        this.suit = suit;
        this.rank = rank;
        Object.freeze(this);
    }

    static of(suit, rank) {
        const key = suit * 16 + rank;
        let card = cards.get(key);
        if (!card) {
            card = new PlayingCard(suit, rank);
            cards.set(key, card);
        }
        return card;
    }

    get isJoker() {
        return Rank.isJoker(this.rank);
    }

    get isRed() {
        return this.suit === Suit.diamonds || this.suit === Suit.hearts;
    }

    display() {
        return `${Suit.display(this.suit)}${Rank.display(this.rank)}`;
    }

    /**
     * The cards this card may be played as when a hand is scored:
     * the good joker is wild, it can stand in for any card of the standard pack,
     * with deuces wild a two can be the two of any suit, any other card is just itself.
     */
    get playableAs() {
        if (this === PlayingCard.goodJoker) {
            return PlayingCard.standardPack;
        }
        if (HandRules.deucesWild && this.rank === Rank.two) {
            return Suit.standard.map(suit => PlayingCard.of(suit, Rank.two));
        }
        return [this];
    }

    /**
     * Plays the wild cards in a hand (the good joker, and the twos when deuces are wild) as the cards that
     * give the best score. The good joker cannot be played as a card already in the hand,
     * but two wild twos can both be played as the same two.
     * A hand without wild cards is returned unchanged.
     * score: a function that takes a hand and returns its BragHandScore
     */
    static playWildCards(hand, score) {
        const choices = hand.map(card => card.playableAs);
        const isWildTwo = hand.map(card => HandRules.deucesWild && card.rank === Rank.two);
        if (choices.every(choice => choice.length === 1)) {
            return hand;
        }
        let bestHand = hand;
        let bestScore = null;
        const play = played => {
            if (played.length === hand.length) {
                const playedScore = score(played);
                if (bestScore === null || playedScore.score > bestScore.score) {
                    bestScore = playedScore;
                    bestHand = played;
                }
                return;
            }
            const index = played.length;
            for (const card of choices[index]) {
                const isDuplicate = played.some((other, i) => other === card && !(isWildTwo[i] && isWildTwo[index]));
                if (!isDuplicate) {
                    play([...played, card]);
                }
            }
        };
        play([]);
        return bestHand;
    }

    /** Two characters, rank then suit: "AH", "td". Jokers are GJ (good) and BJ (bad). Returns null if not a card */
    static unflatten(flattened) {
        switch (flattened.toLowerCase()) {
            case 'gj': return PlayingCard.goodJoker;
            case 'bj': return PlayingCard.badJoker;
        }
        if (flattened.length !== 2) {
            return null;
        }
        const rank = Rank.unflatten(flattened[0]);
        const suit = Suit.unflatten(flattened[1]);
        if (rank === null || suit === null) {
            return null;
        }
        return PlayingCard.of(suit, rank);
    }
}

/** The jokers are only in the pack for the Looky Looky rules */
PlayingCard.goodJoker = PlayingCard.of(Suit.joker, Rank.goodJoker);
PlayingCard.badJoker = PlayingCard.of(Suit.joker, Rank.badJoker);
/** The 52 cards of a standard pack, no jokers */
PlayingCard.standardPack = Object.freeze(Suit.standard.flatMap(suit => Rank.standard.map(rank => PlayingCard.of(suit, rank))));
