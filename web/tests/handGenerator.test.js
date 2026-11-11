// Ported from HandGeneratorTests
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { HandGenerator } from '../js/model/handGenerator.js';
import { PlayerHand } from '../js/model/playerHand.js';
import { BragHandTypes as T, Turn, maxBy } from '../js/model/defines.js';
import { Rank, Suit } from '../js/model/playingCard.js';
import { KQTFlush, QQKPair, cards } from './hands.js';

test('generatePossibleTurns: swapping all 3 is a possibility', () => {
    const playerHand = new PlayerHand(QQKPair);
    const middle = new PlayerHand(KQTFlush);
    const scoredTurns = new HandGenerator(playerHand).generatePossibleTurns(middle);
    assert.equal(scoredTurns.length, 10);
    const all = scoredTurns.filter(scored => Turn.equals(scored.turn, Turn.all()));
    assert.equal(all.length, 1);
    assert.deepEqual(all[0].score, middle.score);
    assert.deepEqual(all[0].middleScore, playerHand.score);
});

test('generatePossibleTurns: the prial is found', () => {
    const playerHand = new PlayerHand(QQKPair);
    const middle = new PlayerHand(KQTFlush);
    const scoredTurns = new HandGenerator(playerHand).generatePossibleTurns(middle);
    const swap = Turn.swap(playerHand.hand[2], middle.hand[1]);
    const found = scoredTurns.filter(scored => Turn.equals(scored.turn, swap));
    assert.equal(found.length, 1);
    assert.equal(found[0].score.type, T.prial);
    assert.equal(found[0].middleScore.type, T.pair);
});

test('generatePossibleTurnsFaceUpOnly ignores the face down card', () => {
    const playerHand = new PlayerHand(cards('qc', 'ks', 'qs'));
    const middle = new PlayerHand(cards('qh', 'js', 'ac'));
    const scoredTurns = new HandGenerator(playerHand).generatePossibleTurnsFaceUpOnly(middle);
    assert.equal(scoredTurns.length, 6);
    const best = maxBy(scoredTurns, scored => scored.score.score);
    assert.equal(best.score.type, T.trotter);
    assert.equal(best.turn.kind, 'swap');
    assert.equal(best.turn.middle.rank, Rank.jack);
    assert.equal(best.turn.hand.suit, Suit.clubs);
});

test('generatePotentialHands', () => {
    const playerHand = new PlayerHand(cards('ac', 'ks', 'qs'));
    const middle = new PlayerHand(cards('5h', '6c', '2d'));
    const scoredTurns = new HandGenerator(playerHand).generatePotentialHands(middle);
    //3 scores when take the down card, 3 scores when take all (vary which card is down)
    assert.equal(scoredTurns.length, 6);
    const best = maxBy(scoredTurns, scored => scored.score.score);
    assert.equal(best.score.type, T.trotter);
    assert.equal(best.turn.kind, 'swap');
    assert.equal(best.turn.hand.rank, Rank.ace);
    assert.equal(best.turn.middle.rank, Rank.five);
    for (const downIndex of [0, 1, 2]) {
        assert.equal(scoredTurns.filter(scored => Turn.equals(scored.turn, Turn.all(downIndex))).length, 1);
    }
    const bestMiddle = maxBy(scoredTurns, scored => scored.middleScore.score);
    assert.equal(bestMiddle.middleScore.type, T.trotter);
});
