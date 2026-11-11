// Ported from OneDownAITests
import { test, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { OneDownAI } from '../js/model/oneDownAI.js';
import { Player } from '../js/model/player.js';
import { PlayerHand } from '../js/model/playerHand.js';
import { HandRules, PlayingCard } from '../js/model/playingCard.js';
import { ActionChoice, Turn, TurnAction } from '../js/model/defines.js';
import { cards } from './hands.js';

afterEach(() => {
    HandRules.deucesWild = false;
});

function createAI(playerCards) {
    const ai = new OneDownAI();
    const player = new Player('HAL', ai);
    player.hand.hand = cards(...playerCards);
    return ai;
}

function swap(player, middle) {
    return Turn.swap(PlayingCard.unflatten(player), PlayingCard.unflatten(middle));
}

/** The first middle card is the one that is face down */
function checkAITurn(playerCards, middleCards, expected) {
    const actual = createAI(playerCards).play(new PlayerHand(cards(...middleCards)));
    assert.ok(Turn.equals(actual, expected), `${Turn.display(expected)} != ${Turn.display(actual)}`);
}

test('Go for the middle: a pair, try for the prial with the odd card', () => {
    checkAITurn(['qd', 'qh', '2s'], ['5h', '3d', '7c'], swap('2s', '5h'));
});

test('Do not go for the middle: the player can get a flush', () => {
    checkAITurn(['qd', 'qh', '2d'], ['5h', '3d', '7c'], swap('qh', '3d'));
});

test('Better pair', () => {
    checkAITurn(['as', 'qd', 'qh'], ['5h', '3d', 'ac'], swap('qd', 'ac'));
    checkAITurn(['qs', '3d', 'qh'], ['5h', 'ad', 'ac'], Turn.all(1));
});

test('Bait: throwing a pair in, show them', () => {
    checkAITurn(['qs', 'qh', '3d'], ['5h', 'ad', 'ac'], Turn.all(2));
    checkAITurn(['3d', 'qs', 'qh'], ['5h', 'ad', 'ac'], Turn.all(0));
});

test('One suit: show the cards of the same suit', () => {
    checkAITurn(['3s', '4s', 'qh'], ['5h', 'ad', 'ac'], Turn.all(2));
    checkAITurn(['3s', 'qh', '4s'], ['5h', 'ad', 'ac'], Turn.all(1));
    checkAITurn(['qh', '7s', '4s'], ['5h', 'ad', 'ac'], Turn.all(0));
});

test('A worse pair in the middle', () => {
    checkAITurn(['qs', 'qh', '6d'], ['5h', 'jd', 'jc'], swap('6d', '5h'));
});

test('Prial in hand', () => {
    //Player should take the face down card
    checkAITurn(['qc', 'qd', 'qh'], ['5h', '3d', 'ac'], swap('qc', '5h'));
    //Player should try for a better prial of aces
    checkAITurn(['qc', 'qd', 'qh'], ['5h', 'ad', 'ac'], Turn.all(2));
    //Player should take the queen
    checkAITurn(['qc', 'qd', 'qh'], ['ah', 'ad', 'qs'], swap('qc', 'qs'));
});

test('Take the bait', () => {
    checkAITurn(['qc', 'kd', 'ah'], ['ah', '2d', '2s'], Turn.all(0));
});

test('Takes the card for a flush, run, trotter or prial', () => {
    checkAITurn(['qc', 'kh', 'ah'], ['ah', '2h', '2s'], swap('qc', '2h'));
    checkAITurn(['qc', 'kh', 'ah'], ['as', '2h', 'jd'], swap('ah', 'jd'));
    checkAITurn(['qc', 'kc', 'ad'], ['ah', 'as', 'jc'], swap('ad', 'jc'));
    checkAITurn(['qc', 'kc', 'kd'], ['ah', 'ac', 'ks'], swap('qc', 'ks'));
});

test('Potential hands', () => {
    checkAITurn(['qc', 'kc', 'ad'], ['2s', '3s', '4s'], swap('ad', '2s'));
    checkAITurn(['2s', '3s', '4s'], ['7d', 'kc', 'qc'], Turn.all(0));
    checkAITurn(['7d', 'ks', 'qd'], ['2s', '3c', '8c'], swap('7d', '2s'));
});

//MARK: - Good joker

test('Good joker: makes a run with the three, better than gambling on the down card', () => {
    checkAITurn(['gj', 'qh', '2s'], ['5h', '3d', '7c'], swap('qh', '3d'));
});

test('Good joker: a higher pair than the joker would make is showing next to the joker, so take all three', () => {
    checkAITurn(['9d', '5h', '2s'], ['5h', 'gj', 'kc'], Turn.all(0));
});

test('Good joker: makes a pair of kings, go for the down card with the odd card, not the joker', () => {
    checkAITurn(['gj', 'kh', '6s'], ['5h', '2d', '9c'], swap('6s', '5h'));
});

test('Good joker: pick it up when it is showing', () => {
    checkAITurn(['9d', 'qh', '2s'], ['5h', 'gj', '7c'], swap('2s', 'gj'));
});

test('Good joker: a pair is showing, but swapping one card makes the same pair and keeps the joker', () => {
    checkAITurn(['gj', '9h', '4s'], ['5h', 'qd', 'qc'], swap('4s', 'qd'));
});

test('Good joker: holding a prial made with the joker, a card has to go, not the joker', () => {
    checkAITurn(['gj', '9h', '9s'], ['5h', '2d', '6c'], swap('9h', '5h'));
    //swapping for the ten leaves a trotter
    checkAITurn(['gj', '9h', '9s'], ['5h', 'th', '6c'], swap('9s', 'th'));
});

//MARK: - Looky Looky actions

const afterLooky = [TurnAction.stashHand, TurnAction.changeMiddle];

function checkAIAction(playerCards, middleCards, expected, { available = TurnAction.allCases, looked = false } = {}) {
    const ai = createAI(playerCards);
    const middle = new PlayerHand(cards(...middleCards));
    if (looked) {
        ai.lookedAt(middle.hand[0]);
    }
    assert.deepEqual(ai.chooseAction(middle, available), expected);
}

function change(card) {
    return ActionChoice.changeMiddle(PlayingCard.unflatten(card));
}

test('Action stash: a hand going nowhere is stashed straightaway', () => {
    checkAIAction(['kh', '7d', '3s'], ['5h', '9c', 'jc'], ActionChoice.stashHand);
});

test('Action stash: not if a pair can be made with a card that is showing', () => {
    checkAIAction(['kh', '7d', '3s'], ['5h', 'kc', '9d'], ActionChoice.looky);
    checkAIAction(['kh', '7d', '3s'], ['5h', 'kc', '9d'], null, { available: afterLooky, looked: true });
});

test('Action stash: going to take the middle anyway, so nothing to lose by trying a new hand first', () => {
    checkAIAction(['kh', 'kd', '3s'], ['ah', 'ac', 'ad'], ActionChoice.stashHand, { available: afterLooky, looked: true });
});

test('Action looky: always, whatever is held or showing', () => {
    checkAIAction(['kh', 'qh', '3s'], ['5h', '9c', '6d'], ActionChoice.looky);
    checkAIAction(['kh', 'kd', '3s'], ['5h', '9c', '6d'], ActionChoice.looky);
    checkAIAction(['kh', '7d', '3s'], ['5h', '9c', '9d'], ActionChoice.looky, { available: [TurnAction.looky, TurnAction.changeMiddle] });
    //A run can already be made, look anyway
    checkAIAction(['kh', 'qd', '3s'], ['5h', 'jc', '7d'], ActionChoice.looky);
});

test('Action change: looked and nothing helps, change the higher of the cards showing', () => {
    checkAIAction(['kh', 'qh', '3s'], ['5d', '9c', '6d'], change('9c'), { available: afterLooky, looked: true });
});

test('Action change: taking the king for a pair, so change the other card', () => {
    checkAIAction(['kh', 'qh', '3s'], ['5d', 'kc', '6d'], change('6d'), { available: afterLooky, looked: true });
});

test('Action change: taking a nine as a better kicker, change the other nine for a chance of the prial', () => {
    checkAIAction(['kh', 'kd', '3s'], ['5d', '9c', '9d'], change('9d'), { available: afterLooky, looked: true });
});

test('Action change, spite: taking the down card for a prial, don\'t leave the pair of nines for the next player', () => {
    checkAIAction(['kh', 'kd', '3s'], ['ks', '9c', '9d'], change('9c'), { available: afterLooky, looked: true });
});

test('Action: nothing left to do', () => {
    checkAIAction(['kh', 'qh', '3s'], ['5d', '9c', '6d'], null, { available: [TurnAction.stashHand], looked: true });
    checkAIAction(['kh', 'qh', '3s'], ['5d', '9c', '6d'], null, { available: [] });
});

test('Action: a player that does not use actions', () => {
    const ai = createAI(['kh', '7d', '3s']);
    ai.usesActions = false;
    assert.equal(ai.chooseAction(new PlayerHand(cards('5h', '9c', 'jc')), TurnAction.allCases), null);
});

test('Having looked, the AI plays with the down card known, then forgets it', () => {
    const ai = createAI(['kh', 'qh', '3s']);
    const middle = new PlayerHand(cards('jh', '9c', '6d'));
    ai.lookedAt(middle.hand[0]);
    assert.ok(Turn.equals(ai.play(middle), swap('3s', 'jh')));
    assert.equal(ai.knowsDownCard(middle), false);
});
