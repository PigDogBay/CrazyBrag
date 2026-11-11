// Ported from CrazyBrag/model/OneDownAI.swift
import { AI } from './ai.js';
import { HandGenerator } from './handGenerator.js';
import { HandResolver } from './handResolver.js';
import { PossibleHandResolver } from './possibleHandResolver.js';
import { PlayingCard, Rank } from './playingCard.js';
import { ActionChoice, BragHandTypes, Turn, TurnAction, maxBy } from './defines.js';

/** The computer player: plays the game where one card of the middle is face down */
export class OneDownAI extends AI {
    constructor() {
        super();
        /** Looky Looky rules: does this player take the optional actions before making their move */
        this.usesActions = true;
        /** Looky Looky rules: the face down middle card, once the player has looked at it this turn */
        this.lookedAtCard = null;
    }

    get hand() {
        return this.player.hand.hand;
    }

    play(middle) {
        const turn = this.decideTurn(middle);
        this.lookedAtCard = null;
        return turn;
    }

    lookedAt(card) {
        this.lookedAtCard = card;
    }

    /** True if the player has looked at the face down card and it is still the one in the middle */
    knowsDownCard(middle) {
        return this.lookedAtCard !== null && this.lookedAtCard === middle.hand[0];
    }

    /**
     * The highest scoring turn from what the player can see: the face up cards,
     * and the face down card as well once they have looked at it
     */
    bestVisibleTurn(middle) {
        const generator = new HandGenerator(this.player.hand);
        const turns = this.knowsDownCard(middle)
            ? generator.generatePossibleTurns(middle)
            : generator.generatePossibleTurnsFaceUpOnly(middle);
        return maxBy(turns, turn => turn.score.score);
    }

    /** Two cards that could become a flush, run, trotter or prial with the right third card */
    isPromisingPair(card1, card2) {
        return new PossibleHandResolver([card1, card2]).createScore().type >= BragHandTypes.flush;
    }

    /** Does the hand hold two cards that work together (or the good joker, which works with anything) */
    isPromising(hand) {
        return this.isPromisingPair(hand[0], hand[1]) || this.isPromisingPair(hand[0], hand[2]) || this.isPromisingPair(hand[1], hand[2]);
    }

    /**
     * Looky Looky rules, which action to take next, if any:
     * - Stash a hand that is going nowhere straightaway: no two cards work together and the cards showing don't help
     * - Always looky at the face down card
     * - Stash the hand if all of the middle is going to be taken anyway, there is nothing to lose
     * - Change a middle card: out of spite if good cards are being left for the next player,
     *   or swap a useless card for a new one that might hit a promising hand
     */
    chooseAction(middle, available) {
        if (!this.usesActions || available.length === 0 || !this.player || this.hand.length !== 3 || middle.hand.length !== 3) {
            return null;
        }
        const best = this.bestVisibleTurn(middle);
        const promising = this.isPromising(this.hand);
        const showing1 = middle.hand[1];
        const showing2 = middle.hand[2];
        const promisingMiddle = this.isPromisingPair(showing1, showing2);

        if (available.includes(TurnAction.stashHand) && !promising && best.score.type < BragHandTypes.pair) {
            return ActionChoice.stashHand;
        }
        if (available.includes(TurnAction.looky) && !this.knowsDownCard(middle)) {
            //Always look, it costs nothing and the move can then be made knowing all of the middle
            return ActionChoice.looky;
        }
        const turn = this.decideTurn(middle);
        if (turn.kind === 'all') {
            //The hand is going in the middle, a new one might be better and if not the middle is still there
            return available.includes(TurnAction.stashHand) ? ActionChoice.stashHand : null;
        }
        if (available.includes(TurnAction.changeMiddle)) {
            //The middle card that is wanted, if it makes a hand
            const taking = best.score.type >= BragHandTypes.pair ? turn.middle : null;
            //The higher card is more use to the other players
            const highestShowing = Rank.score(showing1.rank) >= Rank.score(showing2.rank) ? showing1 : showing2;
            if (promisingMiddle && taking !== showing1 && taking !== showing2
                && new PossibleHandResolver([showing1, showing2]).createScore().type >= BragHandTypes.trotter) {
                //Spite: a pair or two cards of a trotter are showing, don't leave them for the next player
                return ActionChoice.changeMiddle(highestShowing);
            }
            if (promising && best.score.type <= BragHandTypes.pair) {
                //Nothing in the middle hits the hand, try a new card in place of one that is no use
                if (taking === showing1) {
                    return ActionChoice.changeMiddle(showing2);
                }
                if (taking === showing2) {
                    return ActionChoice.changeMiddle(showing1);
                }
                return ActionChoice.changeMiddle(highestShowing);
            }
        }
        return null;
    }

    decideTurn(middle) {
        if (this.knowsDownCard(middle)) {
            //Looky Looky rules: all of the middle is known, so take the best hand on offer
            const best = this.bestVisibleTurn(middle);
            return best.turn.kind === 'all' ? this.createTakeAllTurn() : best.turn;
        }
        const scoredTurn = maxBy(new HandGenerator(this.player.hand).generatePossibleTurnsFaceUpOnly(middle), turn => turn.score.score);
        return this.playerHoldsAPrial(middle, scoredTurn)
            ?? this.pairInTheMiddle(middle, scoredTurn)
            //If have a pair in the hand, maybe try for a prial?
            ?? this.tryForPrial(middle, scoredTurn)
            ?? this.tryForAGoodHand(middle, scoredTurn)
            ?? scoredTurn.turn;
    }

    tryForAGoodHand(middle, bestScoreFaceUp) {
        if (bestScoreFaceUp.score.type !== BragHandTypes.high) {
            return null;
        }
        const potentialTurn = maxBy(new HandGenerator(this.player.hand).generatePotentialHands(middle), turn => turn.score.score);
        if (potentialTurn.score.type >= BragHandTypes.flush) {
            return potentialTurn.turn;
        }
        return null;
    }

    createTakeAllTurn() {
        const [c1, c2, c3] = this.hand;
        //Keep the good joker out of sight
        const jokerIndex = this.hand.indexOf(PlayingCard.goodJoker);
        if (jokerIndex !== -1) {
            return Turn.all(jokerIndex);
        }
        //Bait: if the player is throwing a pair in, show them
        if (c1.rank === c2.rank) {
            return Turn.all(2);
        }
        if (c1.rank === c3.rank) {
            return Turn.all(1);
        }
        if (c2.rank === c3.rank) {
            return Turn.all(0);
        }
        //if player has cards with same suit, show them to lessen the chance of other
        //players getting a flush
        if (c1.suit === c2.suit) {
            return Turn.all(2);
        }
        if (c1.suit === c3.suit) {
            return Turn.all(1);
        }
        return Turn.all(0);
    }

    /** The player has a prial in their hand, unless the same rank is showing should try the middle card */
    playerHoldsAPrial(middle, bestScoreFaceUp) {
        if (bestScoreFaceUp.score.type === BragHandTypes.prial) {
            //player can still make a prial with one of the face up cards
            return null;
        }

        //Does the player hold a prial
        const resolverPlayer = new HandResolver(this.hand);
        if (resolverPlayer.createScore().type !== BragHandTypes.prial) {
            return null;
        }

        const holdsGoodJoker = this.hand.includes(PlayingCard.goodJoker);
        if (holdsGoodJoker && bestScoreFaceUp.score.type > BragHandTypes.pair) {
            //With the good joker a swap can still leave a flush or a run, better than gambling on the down card
            return null;
        }

        //is there a chance of a better prial in the middle?
        //resolverPlayer.hand is the prial as scored, with the good joker played as the third card
        const showing = this.pairShowing(middle);
        if (showing !== null && Rank.score(showing) > Rank.score(resolverPlayer.hand[0].rank)) {
            return this.createTakeAllTurn();
        }
        //Hang on to the good joker
        const swapCard = this.hand.find(card => card !== PlayingCard.goodJoker);
        return Turn.swap(swapCard, middle.hand[0]);
    }

    /** The rank of the pair showing in the middle, the good joker pairs up with the card next to it. Null if no pair */
    pairShowing(middle) {
        const c1 = middle.hand[1];
        const c2 = middle.hand[2];
        if (c1 === PlayingCard.goodJoker) {
            return c2.isJoker ? null : c2.rank;
        }
        if (c2 === PlayingCard.goodJoker) {
            return c1.isJoker ? null : c1.rank;
        }
        return c1.rank === c2.rank && !c1.isJoker ? c1.rank : null;
    }

    pairInTheMiddle(middle, bestScoreFaceUp) {
        const showing = this.pairShowing(middle);
        if (showing === null) {
            return null;
        }
        if (this.hand.includes(PlayingCard.goodJoker)) {
            //Don't throw the good joker in, swapping a card will do just as well
            return null;
        }
        if (middle.hand.slice(1).includes(PlayingCard.goodJoker) &&
            bestScoreFaceUp.score.type === BragHandTypes.pair &&
            ((bestScoreFaceUp.score.score >> 16) & 0xff) >= Rank.score(showing)) {
            //The good joker is showing, picking it up on its own makes as good a pair as taking all three
            return null;
        }
        if (bestScoreFaceUp.score.type > BragHandTypes.pair) {
            //A better hand is available using the face up cards
            return null;
        }

        //Does the player hold a better pair?
        const resolverPlayer = new HandResolver(this.hand);
        if (resolverPlayer.createScore().type === BragHandTypes.pair &&
            Rank.score(resolverPlayer.hand[1].rank) > Rank.score(showing)) {
            return null;
        }
        return this.createTakeAllTurn();
    }

    /**
     * If the player has a pair in their hand, try for the middle
     * if there is not a better pair or hand using the face up cards
     */
    tryForPrial(middle, bestScoreFaceUp) {
        //If you have a pair in the hand and can not improve the hand, then bestScoreFaceUp is a pair
        if (bestScoreFaceUp.score.type !== BragHandTypes.pair) {
            return null;
        }
        //Does the player have a pair in their hand
        const resolverPlayer = new HandResolver(this.hand);
        const currentScore = resolverPlayer.createScore();
        if (currentScore.type !== BragHandTypes.pair) {
            //bestScoreFaceUp is a turn that gets the player a pair
            return null;
        }
        if (HandResolver.removeHighScoreFromPair(currentScore.score) !==
            HandResolver.removeHighScoreFromPair(bestScoreFaceUp.score.score)) {
            //bestScoreFaceUp is a better pair
            return null;
        }

        //Ok lets go for a prial, first need to find which card is not in the pair
        const pairRank = resolverPlayer.pairRank;
        //The good joker is half of the pair, so it stays
        const swapCard = this.hand.find(card => card.rank !== pairRank && card !== PlayingCard.goodJoker);
        if (swapCard) {
            //First card in the middle is down
            return Turn.swap(swapCard, middle.hand[0]);
        }
        throw new Error('A pair with no odd card');
    }
}
