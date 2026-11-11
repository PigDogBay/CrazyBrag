// Ported from SchoolTests
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { School } from '../js/model/school.js';
import * as H from './hands.js';

/** A school of six, each named player given a hand, with the hands resolved */
function schoolWith(hands) {
    const school = new School();
    school.setUpPlayers(5);
    school.playerHowie.hand.hand = hands.howie;
    school.playerBomber.hand.hand = hands.bomber;
    school.playerHolly.hand.hand = hands.holly;
    school.playerChris.hand.hand = hands.chris;
    school.playerGeordie.hand.hand = hands.geordie;
    school.playerHuman.hand.hand = hands.human;
    school.resolveHands();
    return school;
}

function names(players) {
    return players.map(player => player.name).sort();
}

test('determineLosingHands: the lowest hand loses', () => {
    const school = schoolWith({ howie: H.A23Trotter, bomber: H.AKQRun, holly: H.AKJFlush, chris: H.QQKPair, geordie: H.AAQPair, human: H.A23Run });
    assert.deepEqual(names(school.determineLosingHands()), ['Chris']);
    assert.equal(school.isPrialOut(), false);
    assert.equal(school.highestScoringPlayer(), school.playerHowie);
});

test('determineLosingHands: equal lowest hands both lose', () => {
    const school = schoolWith({ howie: H.AKQRun, bomber: H.A23Trotter, holly: H.AKJFlush, chris: H.AKJFlush, geordie: H.JQKRun, human: H.A23Run });
    assert.deepEqual(names(school.determineLosingHands()), ['Chris', 'Pig Dog']);
    assert.equal(school.highestScoringPlayer(), school.playerBomber);
});

test('determineLosingHands: prial out, everyone off', () => {
    const school = schoolWith({ howie: H.A23Trotter, bomber: H.AKQRun, holly: H.AKJFlush, chris: H.PrialOfAces, geordie: H.AAQPair, human: H.A23Run });
    const losers = school.determineLosingHands();
    assert.equal(losers.length, 5);
    assert.ok(!losers.includes(school.playerChris));
    assert.equal(school.isPrialOut(), true);
    assert.equal(school.highestScoringPlayer(), school.playerChris);
});

test('Bullet Proof: a trotter or a lower prial does not lose a life to the winning prial', () => {
    const school = schoolWith({ howie: H.A23Trotter, bomber: H.AKQRun, holly: H.PrialOfKings, chris: H.PrialOfAces, geordie: H.AAQPair, human: H.AKJFlush });
    assert.deepEqual(names(school.determineLosingHands(true)), ['Bomber', 'Geordie', 'You']);
});

test('Bullet Proof only matters when a prial is out, otherwise the lowest hand loses as usual', () => {
    const school = new School();
    school.setUpPlayers(1);
    school.players[0].hand.hand = H.A23Trotter;
    school.players[1].hand.hand = H.JQKTrotter;
    school.resolveHands();
    assert.deepEqual(school.determineLosingHands(true), [school.players[1]]);
});

test('Bullet Proof: everyone else is bullet proof, so nobody loses a life', () => {
    const school = new School();
    school.setUpPlayers(1);
    school.players[0].hand.hand = H.PrialOfAces;
    school.players[1].hand.hand = H.JQKTrotter;
    school.resolveHands();
    assert.equal(school.determineLosingHands(true).length, 0);
    assert.equal(school.determineLosingHands().length, 1);
});

test('Extra life: the first winning prial earns one, later ones do not', () => {
    const school = schoolWith({ howie: H.A23Trotter, bomber: H.AKQRun, holly: H.AKJFlush, chris: H.PrialOfAces, geordie: H.AAQPair, human: H.A23Run });
    assert.equal(school.awardExtraLife(), school.playerChris);
    assert.equal(school.playerChris.lives, 4);
    assert.equal(school.playerHowie.lives, 3);
    //Second winning prial
    assert.equal(school.awardExtraLife(), null);
    assert.equal(school.playerChris.lives, 4);
});

test('Extra life: two prials out, only the winning prial earns it', () => {
    const school = schoolWith({ howie: H.PrialOfThrees, bomber: H.AKQRun, holly: H.AKJFlush, chris: H.PrialOfAces, geordie: H.AAQPair, human: H.A23Run });
    assert.equal(school.awardExtraLife(), school.playerHowie);
    assert.equal(school.playerHowie.lives, 4);
    assert.equal(school.playerChris.lives, 3);
    //Chris has not won with a prial yet, so can still earn the extra life
    assert.equal(school.playerChris.hasHadExtraLife, false);
});

test('Extra life: no prial, no extra life, and the flag is cleared for a new game', () => {
    const school = schoolWith({ howie: H.A23Trotter, bomber: H.AKQRun, holly: H.AKJFlush, chris: H.QQKPair, geordie: H.AAQPair, human: H.A23Run });
    assert.equal(school.awardExtraLife(), null);
    school.playerChris.hasHadExtraLife = true;
    school.setUpPlayers(5);
    assert.equal(school.playerChris.hasHadExtraLife, false);
});

test('setUpPlayers: the human is seat 0, seats are in order', () => {
    const school = new School();
    school.setUpPlayers(4);
    assert.equal(school.players.length, 5);
    assert.equal(school.players[0], school.playerHuman);
    assert.deepEqual(school.players.map(player => player.seat), [0, 1, 2, 3, 4]);
    assert.ok(school.players.includes(school.dealer));
    assert.equal(new Set(school.players).size, 5);
});

test('areAllPlayersOut', () => {
    const school = new School();
    school.setUpPlayers(5);
    assert.equal(school.areAllPlayersOut(), false);
    school.players.forEach(player => { player.lives = 0; });
    assert.equal(school.areAllPlayersOut(), true);
});

test('nextPlayer goes round the table and wraps', () => {
    const school = new School();
    school.setUpPlayers(5);
    assert.equal(school.nextPlayer(school.players[0]), school.players[1]);
    assert.equal(school.nextPlayer(school.players[5]), school.players[0]);
    //A player who is out is skipped
    school.players.splice(1, 1);
    assert.equal(school.nextPlayer(school.players[0]).seat, 2);
});

test('sortPlayersInDealOrder: starts after the dealer, the dealer is last', () => {
    const school = new School();
    school.setUpPlayers(5);
    const seats = () => school.sortPlayersInDealOrder().map(player => player.seat);
    school.dealer = school.players[0];
    assert.deepEqual(seats(), [1, 2, 3, 4, 5, 0]);
    school.dealer = school.players[2];
    assert.deepEqual(seats(), [3, 4, 5, 0, 1, 2]);
    school.dealer = school.players[5];
    assert.deepEqual(seats(), [0, 1, 2, 3, 4, 5]);
    school.players = school.players.filter(player => player.seat <= 1);
    school.dealer = school.players[0];
    assert.deepEqual(seats(), [1, 0]);
});
