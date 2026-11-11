// Ported from HandResolverTests and PossibleHandResolverTests
import { test, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { HandRules, PlayingCard, Rank } from '../js/model/playingCard.js';
import { HandResolver } from '../js/model/handResolver.js';
import { PossibleHandResolver } from '../js/model/possibleHandResolver.js';
import { BragHandTypes as T } from '../js/model/defines.js';
import * as H from './hands.js';
import { cards } from './hands.js';

afterEach(() => {
    HandRules.deucesWild = false;
});

/** Score of a hand: either an array of cards, or card names */
function score(...hand) {
    return new HandResolver(Array.isArray(hand[0]) ? hand[0] : cards(...hand)).createScore();
}

/** Score of two cards showing */
function possible(...hand) {
    return new PossibleHandResolver(Array.isArray(hand[0]) ? hand[0] : cards(...hand)).createScore();
}

/** Each score beats the one after it */
function assertDescending(...scores) {
    for (let i = 1; i < scores.length; i++) {
        assert.ok(scores[i - 1].score > scores[i].score, `${scores[i - 1].display()} should beat ${scores[i].display()}`);
    }
}

test('Hand types', () => {
    assert.equal(score(H.PrialOfAces).type, T.prial);
    assert.equal(score(H.JQKTrotter).type, T.trotter);
    assert.equal(score(H.JQKRun).type, T.run);
    assert.equal(score(H.A23Run).type, T.run);
    assert.equal(score(H.AKQRun).type, T.run);
    assert.equal(score(H.KJTFlush).type, T.flush);
    assert.equal(score(H.QQKPair).type, T.pair);
    assert.equal(score(H.KQ2High).type, T.high);
});

test('Scoring prials: threes are the highest', () => {
    assertDescending(score(H.PrialOfThrees), score(H.PrialOfAces), score(H.PrialOfKings), score(H.StateExpress));
});

test('Scoring trotters and runs: A23 is the highest', () => {
    assertDescending(score(H.A23Trotter), score(H.JQKTrotter));
    assertDescending(score(H.A23Run), score(H.AKQRun), score(H.JQKRun), score(H.Weetabix456Run), score(H.Beehive345Run));
});

test('Scoring flushes, pairs and high cards', () => {
    assertDescending(score(H.AKJFlush), score(H.KQTFlush), score(H.KJTFlush), score(H.KJ9Flush));
    assertDescending(score(H.AAQPair), score(H.QQAPair), score(H.QQKPair));
    assertDescending(score(H.A42High), score(H.KQ3High), score(H.KQ2High));
});

test('Scoring hand types against each other', () => {
    assertDescending(score(H.PrialOfAces), score(H.JQKTrotter), score(H.JQKRun));
    assertDescending(score(H.A23Run), score(H.KJTFlush), score(H.QQKPair), score(H.KQ2High));
});

test('Equal hands in different suits score the same', () => {
    assert.deepEqual(score(H.Beehive345Run), score(H.Beehive345Run2));
});

//MARK: - Bad joker

test('Bad joker: does not make a run or a flush', () => {
    assert.equal(score('qc', 'ks', 'bj').type, T.high);
    assert.equal(score('2s', 'ks', 'bj').type, T.high);
});

test('Bad joker: a pair still counts alongside it, but the joker is the lowest kicker', () => {
    const withJoker = score('7h', 'bj', '7c');
    assert.equal(withJoker.type, T.pair);
    assertDescending(score('7h', '2d', '7c'), withJoker);
    assertDescending(score('9h', 'kc', '2d'), score('9h', 'kc', 'bj'));
});

//MARK: - Good joker, wild

test('Good joker: a pair and the joker is a prial', () => {
    assert.deepEqual(score('kd', 'gj', 'kh'), score(H.PrialOfKings));
    assert.deepEqual(score('gj', '3c', '3s'), score(H.PrialOfThrees));
    assert.deepEqual(score('ac', 'as', 'gj'), score(H.PrialOfAces));
});

test('Good joker: two suited cards that can make a run are a trotter', () => {
    assert.deepEqual(score('2d', 'gj', 'ad'), score(H.A23Trotter));
    assert.deepEqual(score('3d', 'gj', 'ad'), score(H.A23Trotter));
    //QK makes AKQ, which beats JQK
    const akq = score('qs', 'ks', 'gj');
    assert.equal(akq.type, T.trotter);
    assertDescending(akq, score(H.JQKTrotter));
    //the joker fills the gap
    assert.deepEqual(score('js', 'gj', 'ks'), score(H.JQKTrotter));
});

test('Good joker: goes on the top end of a run when it can', () => {
    assert.deepEqual(score('4c', '5d', 'gj'), score(H.Weetabix456Run));
    assert.deepEqual(score('4c', '6d', 'gj'), score(H.Weetabix456Run));
    assert.deepEqual(score('2c', '3d', 'gj'), score(H.A23Run));
    assert.deepEqual(score('ac', 'kd', 'gj'), score(H.AKQRun));
});

test('Good joker: two suited cards that cannot make a run are a flush, the joker the highest card available', () => {
    assert.deepEqual(score('jd', 'gj', 'ad'), score('jd', 'kd', 'ad'));
    assert.equal(score('jd', 'gj', 'ad').type, T.flush);
    //Holding the ace already, the joker is the king
    assert.deepEqual(score('ah', '9h', 'gj'), score('ah', '9h', 'kh'));
});

test('Good joker: otherwise pairs the highest card', () => {
    const pair = score('9c', 'gj', '4d');
    assert.equal(pair.type, T.pair);
    assert.deepEqual(pair, score('9c', '9h', '4d'));
    assert.deepEqual(score('ac', 'gj', '7d'), score('ac', 'ah', '7d'));
});

test('Good joker with the bad joker: pairs the other card, the bad joker is the lowest kicker', () => {
    const pair = score('7h', 'gj', 'bj');
    assert.equal(pair.type, T.pair);
    assertDescending(score('7h', '7d', '2c'), pair, score('6h', '6d', 'ac'));
});

test('Good joker: the scored hand holds the card the joker was played as', () => {
    const resolver = new HandResolver(cards('gj', '9c', '4d'));
    assert.equal(resolver.pairRank, Rank.nine);
    assert.ok(!resolver.hand.includes(PlayingCard.goodJoker));
});

//MARK: - Deuces are wild: a two can be any suit

test('Deuces wild: a two takes the suit of the other two cards to make a flush', () => {
    assert.equal(score('2h', '9s', 'ks').type, T.high);
    HandRules.deucesWild = true;
    const flush = score('2h', '9s', 'ks');
    assert.equal(flush.type, T.flush);
    assert.deepEqual(flush, score('2s', '9s', 'ks'));
    //the other two cards still have to match
    assert.equal(score('2h', '9s', 'kd').type, T.high);
});

test('Deuces wild: a run with a two in it becomes a trotter when the other two cards are suited', () => {
    assert.equal(score('as', '2h', '3s').type, T.run);
    HandRules.deucesWild = true;
    assert.deepEqual(score('as', '2h', '3s'), score(H.A23Trotter));
    assert.equal(score('4s', '2h', '3s').type, T.trotter);
    assert.equal(score('4s', '2h', '3d').type, T.run);
});

test('Deuces wild: two twos both take the suit of the third card, three twos are still a prial', () => {
    assert.equal(score('2h', '2d', 'ks').type, T.pair);
    HandRules.deucesWild = true;
    const flush = score('2h', '2d', 'ks');
    assert.equal(flush.type, T.flush);
    assert.deepEqual(flush, score('2h', '2s', 'ks'));
    //K 2 2 is a low flush
    assertDescending(score('3s', '4s', 'ks'), flush, score('ah', 'ad', 'ks'));
    assert.equal(score('2h', '2s', '2c').type, T.prial);
});

test('Deuces wild: a two is always a two', () => {
    HandRules.deucesWild = true;
    assert.equal(score('2h', 'kd', 'ks').type, T.pair);
    assert.equal(score('2h', '5d', '6s').type, T.high);
    assert.deepEqual(score('2h', '9s', 'ks'), score('2c', '9s', 'ks'));
});

test('Deuces wild with the jokers', () => {
    HandRules.deucesWild = true;
    assert.deepEqual(score('gj', '2h', '3c'), score(H.A23Trotter));
    assert.deepEqual(score('gj', '2h', 'ac'), score(H.A23Trotter));
    assert.deepEqual(score('gj', '2h', 'ks'), score('as', '2s', 'ks'));
    assert.equal(score('gj', '2h', '2d').type, T.prial);
    assert.equal(score('bj', '2h', 'ks').type, T.high);
    //The good joker still cannot be played as a card already in the hand
    assert.deepEqual(score('gj', 'ah', '9h'), score('kh', 'ah', '9h'));
});

//MARK: - Two cards showing

test('Possible hand types', () => {
    assert.equal(possible('ac', 'as').type, T.prial);
    assert.equal(possible('9c', '7c').type, T.trotter);
    assert.equal(possible('qc', 'ks').type, T.run);
    assert.equal(possible('ac', '3s').type, T.run);
    assert.equal(possible('kc', 'js').type, T.run);
    assert.equal(possible('ks', '2s').type, T.flush);
    assert.equal(possible('kc', '2s').type, T.high);
});

test('Possible hands: the jokers', () => {
    //The bad joker showing cannot become a run, flush or prial
    assert.equal(possible('qc', 'bj').type, T.high);
    assert.equal(possible('bj', 'gj').type, T.high);
    //The good joker is wild, with any other card it is a possible prial of that rank
    const withJoker = possible('qc', 'gj');
    assert.equal(withJoker.type, T.prial);
    assert.deepEqual(withJoker, possible('qc', 'qh'));
});

test('Possible hands: deuces wild, a two showing takes the suit of the card next to it', () => {
    assert.equal(possible('2h', 'ks').type, T.high);
    assert.equal(possible('2h', 'as').type, T.run);
    HandRules.deucesWild = true;
    assert.equal(possible('2h', 'ks').type, T.flush);
    assert.equal(possible('2h', 'as').type, T.trotter);
});

test('Possible hands scoring', () => {
    //Possible prial of 3's is scored lower than 4
    assertDescending(possible(H.PrialOfFours.slice(0, 2)), possible(H.PrialOfThrees.slice(0, 2)));
    assertDescending(possible(H.PrialOfAces.slice(0, 2)), possible(H.PrialOfKings.slice(0, 2)), possible(H.StateExpress.slice(0, 2)));
    //Runs are scored by highest cards: AQ is better than A2, 34 than 23, KQ than KJ
    assertDescending(possible('ac', 'qs'), possible('ac', '2s'));
    assertDescending(possible('3c', '4s'), possible('2c', '3s'));
    assertDescending(possible('kc', 'qs'), possible('kc', 'js'));
    assertDescending(possible('ac', '4c'), possible('ks', '4s'));
    assertDescending(possible('ac', 'tc'), possible('as', '9s'));
});
