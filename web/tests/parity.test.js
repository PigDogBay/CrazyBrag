// Checks that this JavaScript model plays exactly as the Swift model of the iOS game does.
// The same sums are worked out by testPortParity in CrazyBragTests/OneDownAITests.swift: every possible hand is
// scored, and the computer player is asked for its actions and its move in 20,000 made up deals.
// If a rule or the computer player's strategy changes, change both games and put the new sums in both tests.
import { test, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { HandRules, PlayingCard } from '../js/model/playingCard.js';
import { HandResolver } from '../js/model/handResolver.js';
import { PossibleHandResolver } from '../js/model/possibleHandResolver.js';
import { OneDownAI } from '../js/model/oneDownAI.js';
import { Player } from '../js/model/player.js';
import { PlayerHand } from '../js/model/playerHand.js';
import { TurnAction } from '../js/model/defines.js';

export const SCORES_SUM = 304675294;
export const DECISIONS_SUM = 223628548;

const M = 1000000007;
const pack = [...PlayingCard.standardPack, PlayingCard.goodJoker, PlayingCard.badJoker];

afterEach(() => {
    HandRules.deucesWild = false;
});

export function scoresSum() {
    let sum = 0;
    for (const wild of [false, true]) {
        HandRules.deucesWild = wild;
        for (let i = 0; i < 54; i++) {
            for (let j = i + 1; j < 54; j++) {
                for (let k = j + 1; k < 54; k++) {
                    sum = (sum * 31 + new HandResolver([pack[i], pack[j], pack[k]]).createScore().score) % M;
                }
            }
        }
        for (let i = 0; i < 54; i++) {
            for (let j = 0; j < 54; j++) {
                if (i !== j) {
                    sum = (sum * 31 + new PossibleHandResolver([pack[i], pack[j]]).createScore().score) % M;
                }
            }
        }
    }
    return sum;
}

function actionCode(choice) {
    if (!choice) {
        return 0;
    }
    switch (choice.action) {
        case TurnAction.looky: return 1;
        case TurnAction.stashHand: return 2;
        default: return 100 + pack.indexOf(choice.card);
    }
}

function turnCode(turn) {
    return turn.kind === 'swap' ? 1000 + pack.indexOf(turn.hand) * 54 + pack.indexOf(turn.middle) : 5000 + turn.downIndex;
}

export function decisionsSum() {
    let x = 12345;
    let sum = 0;
    for (let n = 0; n < 20000; n++) {
        const picked = [];
        while (picked.length < 6) {
            x = (x * 48271) % 2147483647;
            const index = x % 54;
            if (!picked.includes(index)) {
                picked.push(index);
            }
        }
        HandRules.deucesWild = n % 2 === 1;
        const ai = new OneDownAI();
        const player = new Player('HAL', ai);
        player.hand.hand = picked.slice(0, 3).map(index => pack[index]);
        const middle = new PlayerHand(picked.slice(3).map(index => pack[index]));
        sum = (sum * 31 + actionCode(ai.chooseAction(middle, TurnAction.allCases))) % M;
        if (n % 3 === 0) {
            ai.lookedAt(middle.hand[0]);
            sum = (sum * 31 + actionCode(ai.chooseAction(middle, [TurnAction.stashHand, TurnAction.changeMiddle]))) % M;
        }
        sum = (sum * 31 + turnCode(ai.play(middle))) % M;
    }
    return sum;
}

test('Parity with the Swift game: the score of every hand', () => {
    assert.equal(scoresSum(), SCORES_SUM);
});

test('Parity with the Swift game: the computer player\'s decisions', () => {
    assert.equal(decisionsSum(), DECISIONS_SUM);
});
