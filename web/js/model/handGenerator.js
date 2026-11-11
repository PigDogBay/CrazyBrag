// Ported from CrazyBrag/model/HandGenerator.swift
import { PlayerHand } from './playerHand.js';
import { PossibleHandResolver } from './possibleHandResolver.js';
import { ScoredTurn, Turn } from './defines.js';

/** Lists the turns a player could make, with the score of the hand and of the middle that would result */
export class HandGenerator {
    constructor(playerHand) {
        this.playerHand = playerHand;
    }

    createdScoredTurn(middle, playerCard, middleCard) {
        const possibleHand = new PlayerHand(this.playerHand.hand);
        possibleHand.replace(playerCard, middleCard);

        const possibleMiddle = new PlayerHand(middle.hand);
        possibleMiddle.replace(middleCard, playerCard);

        return new ScoredTurn(Turn.swap(playerCard, middleCard), possibleHand.score, possibleMiddle.score);
    }

    generatePossibleTurns(middle) {
        const turns = [];
        for (const playerCard of this.playerHand.hand) {
            for (const middleCard of middle.hand) {
                turns.push(this.createdScoredTurn(middle, playerCard, middleCard));
            }
        }
        //Finally swap all 3
        turns.push(new ScoredTurn(Turn.all(), middle.score, this.playerHand.score));
        return turns;
    }

    /**
     * Hand generator for the 1 down in middle variation.
     * This will not consider the unknown card in the middle that is face down
     */
    generatePossibleTurnsFaceUpOnly(middle) {
        const turns = [];
        for (const playerCard of this.playerHand.hand) {
            //First card is face down, so ignore it
            for (const middleCard of middle.hand.slice(1)) {
                turns.push(this.createdScoredTurn(middle, playerCard, middleCard));
            }
        }
        return turns;
    }

    /** When the player has to take the face down middle card, which is the best card to throw in? */
    createdScoredTurnUsingDownCard(middle, indexToSwap) {
        //Player hand's throw in the card at indexToSwap, face down
        const swapped = this.playerHand.hand[indexToSwap];
        //Get remaining two cards in the hand
        const hand = this.playerHand.hand.filter(card => card !== swapped);
        //What's the best possible score with this hand
        const score = new PossibleHandResolver(hand).createScore();

        //Generate the result for comparison
        const turn = Turn.swap(swapped, middle.hand[0]);
        const middleScore = new PossibleHandResolver([middle.hand[1], middle.hand[2]]).createScore();
        return new ScoredTurn(turn, score, middleScore);
    }

    /**
     * What is the score if the player takes all the cards, this calculates the score of the hand the player will
     * place in the middle.
     * downIndex: index of the card in the player's hand to place face down
     */
    createAllInOneDown(middleScore, downIndex) {
        const downCard = this.playerHand.hand[downIndex];
        //Calculate the possible middle score when the player throws in all of their hand
        const faceUpCards = this.playerHand.hand.filter(card => card !== downCard);
        const score = new PossibleHandResolver(faceUpCards).createScore();
        return new ScoredTurn(Turn.all(downIndex), middleScore, score);
    }

    generatePotentialHands(middle) {
        const turns = [];
        for (let i = 0; i <= 2; i++) {
            const scoredTurn = this.createdScoredTurnUsingDownCard(middle, i);
            turns.push(scoredTurn);
            //All In, generate a potential score for the middle (maybe the AI will want to bait?)
            //The potential hand score will be the current middle score
            turns.push(this.createAllInOneDown(scoredTurn.middleScore, i));
        }
        return turns;
    }
}
