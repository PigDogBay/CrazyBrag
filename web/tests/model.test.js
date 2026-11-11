// Ported from ModelTests
import { test, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { GameState, Model } from '../js/model/model.js';
import { HandRules } from '../js/model/playingCard.js';
import { DealtCard, Turn, TurnAction } from '../js/model/defines.js';
import { GameUpdateLogger } from '../js/model/gameUpdateLogger.js';
import { A23Trotter, Beehive345Run, Beehive345Run2, PrialOfKings } from './hands.js';

afterEach(() => {
    //Setting up a Looky Looky game switches this on for every hand that is scored
    HandRules.deucesWild = false;
});

/** A game listener that records what it is told */
class Recorder {
    constructor() {
        this.everyoneOutSoReplayRoundCalled = false;
        this.pullThePegCalled = false;
        this.extraLifePlayer = null;
        this.roundLosers = null;
        this.actionResults = [];
    }
    actionTaken(player, action) { this.actionResults.push(action); }
    roundEnded(losingPlayers, extraLife) { this.extraLifePlayer = extraLife; this.roundLosers = losingPlayers; }
    pullThePeg(outPlayers) { this.pullThePegCalled = true; }
    everyoneOutSoReplayRound() { this.everyoneOutSoReplayRoundCalled = true; }
}

/** Two players given these hands (taken out of the deck, as they are returned to it), then the round is scored */
function scoreRound({ lookyLooky, hands, lives = 3, hadExtraLife = false }) {
    const model = new Model();
    const recorder = new Recorder();
    model.lookyLooky = lookyLooky;
    model.gameListener = recorder;
    model.setUpGame(1);
    model.school.players[0].hasHadExtraLife = hadExtraLife;
    model.school.players.forEach((player, i) => {
        player.lives = lives;
        for (const card of hands[i]) {
            model.deck.remove(card);
            player.hand.receive(card);
        }
    });
    model.gameState = GameState.scoreRound;
    model.updateState();
    return { model, recorder, players: model.school.players };
}

test('Everybody out: equal hands on their last lives, so the round is replayed', () => {
    const { model, recorder, players } = scoreRound({ lookyLooky: false, hands: [Beehive345Run, Beehive345Run2], lives: 1 });
    assert.equal(recorder.everyoneOutSoReplayRoundCalled, true);
    assert.equal(recorder.pullThePegCalled, false);
    assert.equal(model.gameState, GameState.selectDealer);
    assert.deepEqual(players.map(player => player.lives), [1, 1]);
    assert.equal(model.deck.count, 52);
});

test('Looky Looky extra life: the first winning prial gains a life and the other player is safe', () => {
    const { model, recorder, players } = scoreRound({ lookyLooky: true, hands: [PrialOfKings, Beehive345Run] });
    assert.deepEqual(players.map(player => player.lives), [4, 3]);
    assert.equal(recorder.extraLifePlayer, players[0]);
    assert.deepEqual(recorder.roundLosers, []);
    assert.equal(model.gameState, GameState.updateLives);
});

test('Looky Looky extra life: the second winning prial works as usual', () => {
    const { recorder, players } = scoreRound({ lookyLooky: true, hands: [PrialOfKings, Beehive345Run], hadExtraLife: true });
    assert.deepEqual(players.map(player => player.lives), [3, 2]);
    assert.equal(recorder.extraLifePlayer, null);
});

test('Standard rules: no extra life for a prial', () => {
    const { recorder, players } = scoreRound({ lookyLooky: false, hands: [PrialOfKings, Beehive345Run] });
    assert.deepEqual(players.map(player => player.lives), [3, 2]);
    assert.equal(recorder.extraLifePlayer, null);
});

test('Looky Looky bullet proof: the trotter does not lose a life to the prial, the round ends with no losers', () => {
    const { model, recorder, players } = scoreRound({ lookyLooky: true, hands: [PrialOfKings, A23Trotter], hadExtraLife: true });
    assert.deepEqual(players.map(player => player.lives), [3, 3]);
    assert.deepEqual(recorder.roundLosers, []);
    assert.equal(recorder.extraLifePlayer, null);
    assert.equal(model.gameState, GameState.updateLives);
    assert.equal(recorder.everyoneOutSoReplayRoundCalled, false);
});

test('Standard rules: the trotter loses a life to the prial', () => {
    const { recorder, players } = scoreRound({ lookyLooky: false, hands: [PrialOfKings, A23Trotter], hadExtraLife: true });
    assert.equal(players[1].lives, 2);
    assert.equal(recorder.roundLosers.length, 1);
});

/** The computer players play whole games against each other, the logger is run but its text is thrown away */
function computerPlayGames(model, numberOfGames) {
    let lines = 0;
    model.gameListener = new GameUpdateLogger(() => { lines += 1; });
    for (let game = 0; game < numberOfGames; game++) {
        model.setUpGame(5);
        //remove human player
        model.school.players.shift();
        let steps = 0;
        while (model.gameState !== GameState.gameOver) {
            model.updateState();
            steps += 1;
            assert.ok(steps < 100000, 'The game does not end');
        }
        //Run game over state
        model.updateState();
    }
    assert.ok(lines > 0);
}

test('Play 100 games, standard rules', () => {
    const model = new Model();
    computerPlayGames(model, 100);
    assert.equal(model.gameState, GameState.gameOver);
    assert.equal(model.school.players.length, 1);
    assert.equal(model.deck.max, 52);
    assert.equal(model.school.getAllPlayers.reduce((sum, player) => sum + player.gamesWon, 0), 100);
});

test('Play 100 games, Looky Looky rules: the computer players cope with the jokers and take actions', () => {
    const model = new Model();
    model.lookyLooky = true;
    computerPlayGames(model, 100);
    assert.equal(model.gameState, GameState.gameOver);
    assert.equal(model.school.players.length, 1);
    assert.equal(model.deck.max, 54);
});

test('Looky Looky sets up the jokers and wild twos, a standard game takes them away', () => {
    const model = new Model();
    model.lookyLooky = true;
    model.setUpGame(4);
    assert.equal(model.deck.count, 54);
    assert.equal(HandRules.deucesWild, true);
    model.lookyLooky = false;
    model.setUpGame(4);
    assert.equal(model.deck.count, 52);
    assert.equal(HandRules.deucesWild, false);
});

test('Dealing: three cards each and three in the middle, in deal order', () => {
    const model = new Model();
    let dealt = null;
    model.gameListener = { dealingDone(dealtCards) { dealt = dealtCards; } };
    model.setUpGame(4);
    model.updateState();
    model.updateState();
    assert.equal(model.gameState, GameState.reveal);
    assert.equal(dealt.length, 18);
    assert.equal(model.deck.count, 52 - 18);
    assert.equal(model.middle.hand.length, 3);
    model.school.players.forEach(player => assert.equal(player.hand.hand.length, 3));
    //The dealer is dealt to last of the players, then the middle
    assert.equal(dealt[4].seat, model.school.dealer.seat);
    assert.equal(dealt[5].isMiddle, true);
    assert.deepEqual(dealt.filter(d => d.isMiddle).map(d => d.card), model.middle.hand);
    assert.deepEqual(dealt.filter(d => d.isMiddle).map(d => d.cardCount), [1, 2, 3]);
});

//MARK: - Looky Looky actions

/** A game dealt and stepped on to the first player's turn, waiting for them to make their move */
function startTurn(lookyLooky) {
    const model = new Model();
    const recorder = new Recorder();
    model.lookyLooky = lookyLooky;
    model.gameListener = recorder;
    model.setUpGame(4);
    //select dealer, deal, reveal, turn start
    for (let i = 0; i < 4; i++) {
        model.updateState();
    }
    assert.equal(model.gameState, GameState.turnEnd);
    return { model, recorder };
}

test('Actions: two of the three can be taken, each only once', () => {
    const { model, recorder } = startTurn(true);
    TurnAction.allCases.forEach(action => assert.equal(model.canTake(action), true));
    assert.notEqual(model.takeLooky(), null);
    assert.equal(model.canTake(TurnAction.looky), false);
    assert.equal(model.takeLooky(), null);
    assert.equal(model.canTake(TurnAction.stashHand), true);
    assert.equal(model.takeStashHand(), true);
    //That is two, so the third is not allowed
    assert.equal(model.canTake(TurnAction.changeMiddle), false);
    assert.equal(model.takeChangeMiddle(model.middle.hand[1]), false);
    assert.equal(recorder.actionResults.length, 2);
    assert.deepEqual(model.actionsTaken, [TurnAction.looky, TurnAction.stashHand]);
});

test('Actions: none in a standard game, nor before a turn has started', () => {
    const { model, recorder } = startTurn(false);
    TurnAction.allCases.forEach(action => assert.equal(model.canTake(action), false));
    assert.equal(model.takeLooky(), null);
    assert.equal(model.takeStashHand(), false);
    assert.equal(recorder.actionResults.length, 0);

    const model2 = new Model();
    model2.lookyLooky = true;
    model2.setUpGame(4);
    TurnAction.allCases.forEach(action => assert.equal(model2.canTake(action), false));
});

test('Looky gives the face down card, the first card of the middle', () => {
    const { model, recorder } = startTurn(true);
    assert.equal(model.takeLooky(), model.middle.hand[0]);
    assert.equal(recorder.actionResults[0].action, TurnAction.looky);
    assert.equal(recorder.actionResults[0].card, model.middle.hand[0]);
});

test('Stash hand: three new cards, the old ones are back in the deck', () => {
    const { model, recorder } = startTurn(true);
    const player = model.currentPlayer;
    const old = [...player.hand.hand];
    const deckCount = model.deck.count;
    assert.equal(model.takeStashHand(), true);
    assert.equal(player.hand.hand.length, 3);
    for (const card of old) {
        assert.ok(!player.hand.hand.includes(card));
        assert.ok(model.deck.deck.includes(card));
    }
    assert.equal(model.deck.count, deckCount);
    const result = recorder.actionResults[0];
    assert.equal(result.action, TurnAction.stashHand);
    assert.deepEqual(result.discarded, old);
    assert.deepEqual(result.dealt.map(dealt => dealt.card), player.hand.hand);
    assert.deepEqual(result.dealt.map(dealt => dealt.seat), [player.seat, player.seat, player.seat]);
});

test('Change a middle card: the new card takes the old card\'s place', () => {
    const { model, recorder } = startTurn(true);
    const old = [...model.middle.hand];
    const deckCount = model.deck.count;
    assert.equal(model.takeChangeMiddle(old[1]), true);
    assert.equal(model.middle.hand.length, 3);
    assert.equal(model.middle.hand[0], old[0]);
    assert.notEqual(model.middle.hand[1], old[1]);
    assert.equal(model.middle.hand[2], old[2]);
    assert.ok(model.deck.deck.includes(old[1]));
    assert.equal(model.deck.count, deckCount);
    const result = recorder.actionResults[0];
    assert.equal(result.action, TurnAction.changeMiddle);
    assert.equal(result.discarded, old[1]);
    assert.equal(result.dealt.card, model.middle.hand[1]);
    assert.equal(result.dealt.cardCount, 2);
    assert.equal(result.dealt.isMiddle, true);
});

test('Change a middle card: not a card that is not in the middle, and the action is not used up', () => {
    const { model } = startTurn(true);
    assert.equal(model.takeChangeMiddle(model.currentPlayer.hand.hand[0]), false);
    assert.equal(model.canTake(TurnAction.changeMiddle), true);
    //The face down card can be changed
    const down = model.middle.hand[0];
    assert.equal(model.takeChangeMiddle(down), true);
    assert.notEqual(model.middle.hand[0], down);
});

test('Actions are available again on the next player\'s turn, and the round still ends with a full deck', () => {
    const { model } = startTurn(true);
    assert.equal(model.takeStashHand(), true);
    assert.equal(model.takeChangeMiddle(model.middle.hand[2]), true);
    //If it is the human player's turn their move has to be supplied
    model.school.humanAI.turn = Turn.all(0);
    const first = model.currentPlayer;
    model.updateState();
    assert.equal(model.gameState, GameState.turnStart);
    model.updateState();
    assert.notEqual(model.currentPlayer, first);
    TurnAction.allCases.forEach(action => assert.equal(model.canTake(action), true));
    assert.equal(model.actionsTaken.length, 0);
    //Play out the round, the cards are counted when they are stashed
    while (model.gameState !== GameState.updateLives && model.gameState !== GameState.selectDealer) {
        model.updateState();
    }
    assert.equal(model.deck.count, 54);
});

//MARK: - The human player's selection

test('Human selection: swap one card, or all three with the first selected face down', () => {
    const { model } = startTurn(false);
    const hand = model.school.playerHuman.hand.hand;
    const middleCard = model.middle.hand[2];
    assert.equal(model.toTouchableCard(model.school.players[1].hand.hand[0]), null);
    const fromHand = model.toTouchableCard(hand[1]);
    const fromMiddle = model.toTouchableCard(middleCard);
    assert.deepEqual(fromHand, DealtCard.toPlayer(0, hand[1], 2));
    assert.deepEqual(fromMiddle, DealtCard.toMiddle(middleCard, 3));

    //Not the player's turn yet
    assert.equal(model.validate(fromHand), false);
    model.isPlayersTurn = true;
    assert.equal(model.validate(fromHand), true);
    model.selectedCards = [fromHand];
    assert.equal(model.checkIfSwapped(), null);
    assert.equal(model.validate(fromMiddle), true);
    model.selectedCards = [fromHand, fromMiddle];
    assert.ok(Turn.equals(model.checkIfSwapped(), Turn.swap(hand[1], middleCard)));
    //Only one middle card
    assert.equal(model.validate(model.toTouchableCard(model.middle.hand[1])), false);

    model.selectedCards = [fromHand, model.toTouchableCard(hand[0])];
    assert.equal(model.checkIfAllIn(), null);
    //Two hand cards selected, so the middle cannot be
    assert.equal(model.validate(fromMiddle), false);
    model.selectedCards.push(model.toTouchableCard(hand[2]));
    assert.ok(Turn.equals(model.checkIfAllIn(), Turn.all(1)));
});
