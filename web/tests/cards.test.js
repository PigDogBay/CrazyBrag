// Ported from SuitTests, RankTests, PlayingCardTests, DeckTests, ExampleHandTests and StatsTests
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { PlayingCard, Rank, Suit } from '../js/model/playingCard.js';
import { Deck } from '../js/model/deck.js';
import { CardAlreadyInThePackError } from '../js/model/defines.js';
import { ExampleHand } from '../js/model/exampleHand.js';
import { Stats } from '../js/model/stats.js';

test('Suit unflatten', () => {
    assert.equal(Suit.unflatten('C'), Suit.clubs);
    assert.equal(Suit.unflatten('d'), Suit.diamonds);
    assert.equal(Suit.unflatten('H'), Suit.hearts);
    assert.equal(Suit.unflatten('s'), Suit.spades);
    for (const bad of ['', 'x', '2', 'spades']) {
        assert.equal(Suit.unflatten(bad), null);
    }
});

test('Rank unflatten', () => {
    const expected = [Rank.ace, Rank.two, Rank.three, Rank.four, Rank.five, Rank.six, Rank.seven, Rank.eight, Rank.nine,
        Rank.ten, Rank.jack, Rank.queen, Rank.king];
    ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'j', 'Q', 'k'].forEach((text, i) => {
        assert.equal(Rank.unflatten(text), expected[i]);
    });
    for (const bad of ['', 'X', 'f', 'ace']) {
        assert.equal(Rank.unflatten(bad), null);
    }
});

test('Rank score: ace high, jokers lowest', () => {
    assert.equal(Rank.score(Rank.ace), 14);
    assert.equal(Rank.score(Rank.two), 2);
    assert.equal(Rank.score(Rank.king), 13);
    assert.equal(Rank.score(Rank.goodJoker), 0);
    assert.equal(Rank.score(Rank.badJoker), 0);
});

test('PlayingCard unflatten', () => {
    assert.equal(PlayingCard.unflatten('AH'), PlayingCard.of(Suit.hearts, Rank.ace));
    assert.equal(PlayingCard.unflatten('jd'), PlayingCard.of(Suit.diamonds, Rank.jack));
    assert.equal(PlayingCard.unflatten('GJ'), PlayingCard.goodJoker);
    assert.equal(PlayingCard.unflatten('bj'), PlayingCard.badJoker);
    for (const bad of ['', 'HA', 'Ax', 'xH', 'AHA']) {
        assert.equal(PlayingCard.unflatten(bad), null);
    }
});

test('There is one object per card', () => {
    assert.equal(PlayingCard.standardPack.length, 52);
    assert.equal(new Set(PlayingCard.standardPack).size, 52);
    assert.ok(PlayingCard.standardPack.includes(PlayingCard.unflatten('td')));
    assert.ok(!PlayingCard.standardPack.some(card => card.isJoker));
});

test('Deck create', () => {
    const deck = new Deck();
    assert.equal(deck.max, 52);
    deck.createDeck();
    assert.equal(deck.count, 52);
    assert.ok(!deck.deck.some(card => card.isJoker));
});

test('Deck create: Looky Looky rules add the two jokers', () => {
    const deck = new Deck();
    deck.hasJokers = true;
    assert.equal(deck.max, 54);
    deck.createDeck();
    assert.equal(deck.count, 54);
    assert.ok(deck.deck.includes(PlayingCard.goodJoker));
    assert.ok(deck.deck.includes(PlayingCard.badJoker));
    assert.equal(deck.deck.filter(card => card.isJoker).length, 2);
    //Switching the jokers off again gives a standard pack
    deck.hasJokers = false;
    deck.createDeck();
    assert.equal(deck.count, 52);
});

test('Deck deal and shuffle', () => {
    const deck = new Deck();
    deck.createDeck();
    deck.shuffle();
    assert.equal(new Set(deck.deck).size, 52);
    const card = deck.deal();
    assert.equal(deck.count, 51);
    assert.ok(!deck.deck.includes(card));
});

test('Deck receive', () => {
    const deck = new Deck();
    deck.createDeck();
    const card = deck.deal();
    deck.receive([card]);
    assert.equal(deck.count, 52);
    assert.equal(deck.deck[51], card);
    assert.throws(() => deck.receive([card]), error => error instanceof CardAlreadyInThePackError && error.card === card);
    assert.equal(deck.count, 52);
});

test('Deck cut', () => {
    const deck = new Deck();
    deck.createDeck();
    deck.cut(1000);
    assert.equal(deck.count, 52);
    deck.cut(21);
    assert.equal(deck.count, 21);
    deck.cut(0);
    assert.equal(deck.count, 0);
});

test('ExampleHand unflatten', () => {
    const actual = ExampleHand.unflatten('2h,2c,jd,Dogs');
    assert.equal(actual.name, 'Dogs');
    assert.deepEqual(actual.hand, [PlayingCard.of(Suit.hearts, Rank.two), PlayingCard.of(Suit.clubs, Rank.two), PlayingCard.of(Suit.diamonds, Rank.jack)]);
    for (const bad of ['', '2h,2c,jd', '2x,2c,jd,Dogs', '2h,2c,jd,Dogs,pair']) {
        assert.equal(ExampleHand.unflatten(bad), null);
    }
});

test('ExampleHand examples', () => {
    const examples = ExampleHand.examples();
    assert.equal(examples.length, 34);
    for (const example of examples) {
        assert.ok(example.name.length > 0);
        assert.equal(example.hand.length, 3);
    }
});

test('Stats win rate', () => {
    assert.equal(new Stats(0, 0).winRate, 0.0);
    assert.equal(new Stats(20, 10).winRate, 0.5);
    assert.equal(new Stats(0, 0).winRateText, '0%');
    assert.equal(new Stats(20, 5).winRateText, '25%');
});

test('Stats rank', () => {
    assert.equal(new Stats(100, 0).rank, 'Cowpoke');
    assert.equal(new Stats(100, 2).rank, 'Buckaroo');
    assert.equal(new Stats(100, 100).rank, 'Card Sharp');
    assert.equal(new Stats(100, 1000).rank, 'Card King');
    for (let won = 0; won <= 999; won++) {
        assert.notEqual(new Stats(1000, won).rank, 'Card King');
    }
    assert.equal(new Stats(1000, 999).rank, 'Navajo');
});
