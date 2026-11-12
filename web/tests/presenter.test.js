// The presenter and its play states, driven without a screen. These tests are new, the iOS game has none for its presenter
import { test, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { ActionButtonState, GamePresenter, PlayerStatus } from '../js/presenter/gamePresenter.js';
import { IPadLayout, IPhoneLayout, Layer, StartLayout, point } from '../js/presenter/layout.js';
import { StartPresenter } from '../js/presenter/startPresenter.js';
import { MemoryStorage, Settings } from '../js/settings.js';
import { GameState } from '../js/model/model.js';
import { DealtCard, TurnAction } from '../js/model/defines.js';
import { HandRules } from '../js/model/playingCard.js';
import { FakeStartView, FakeView } from './fakeView.js';
import { PrialOfThrees, cards } from './hands.js';

afterEach(() => {
    HandRules.deucesWild = false;
});

/** A game set up on a fake view, with a clock that the test moves on */
function createGame({ lookyLooky = false, layout = new IPadLayout(), autoPlay = false } = {}) {
    const settings = new Settings(new MemoryStorage());
    settings.lookyLooky = lookyLooky;
    const presenter = new GamePresenter({ tableLayout: layout, settings });
    presenter.autoPlayEnabled = autoPlay;
    const view = new FakeView();
    presenter.setUpGame(view);
    let time = 0;
    const game = {
        presenter, view, settings, model: presenter.model,
        /** Moves the clock on in tenths of a second until the condition is true */
        runUntil(condition, limit = 600) {
            const end = time + limit;
            while (!condition()) {
                time += 0.1;
                assert.ok(time < end, 'Waited too long');
                presenter.update(time);
            }
        },
        runUntilHumansTurn() {
            game.runUntil(() => game.model.isPlayersTurn);
        },
        /** Lets the time pass */
        run(seconds) {
            const end = time + seconds;
            game.runUntil(() => time >= end, seconds + 1);
        },
        /** Plays the round, with random moves for the human, until the last player has played and the hands are about to be shown */
        runUntilEveryoneHasPlayed() {
            presenter.autoPlayEnabled = true;
            game.runUntil(() => game.model.gameState === GameState.showHands);
            presenter.autoPlayEnabled = false;
        },
    };
    return game;
}

//MARK: - Settings and layouts

test('Settings: defaults, and they are kept in the storage', () => {
    const storage = new MemoryStorage();
    const settings = new Settings(storage);
    assert.equal(settings.lookyLooky, true);
    assert.equal(settings.markedDeck, true);
    assert.equal(settings.gamesPlayed, 0);
    settings.lookyLooky = false;
    settings.gamesPlayed = settings.gamesPlayed + 1;
    const again = new Settings(storage);
    assert.equal(again.lookyLooky, false);
    assert.equal(again.markedDeck, true);
    assert.equal(again.gamesPlayed, 1);
});

test('Settings: a storage that refuses to work is survived', () => {
    const broken = { getItem() { throw new Error('denied'); }, setItem() { throw new Error('denied'); } };
    const settings = new Settings(broken);
    settings.gamesWon = 5;
    assert.equal(settings.gamesWon, 0);
    assert.equal(settings.lookyLooky, true);
});

test('Layouts: seats, card positions and the number of computer players', () => {
    const pad = new IPadLayout();
    assert.equal(pad.numberOfAIPlayers, 5);
    assert.deepEqual(pad.getPosition(DealtCard.toMiddle(null, 1)), point(402, 384));
    assert.deepEqual(pad.getPosition(DealtCard.toMiddle(null, 2)), point(512.5, 384));
    assert.deepEqual(pad.getPosition(DealtCard.toPlayer(0, null, 3)), point(623, 114.5));
    assert.deepEqual(pad.getNamePosition(5), point(772, 469));
    assert.deepEqual(pad.getLivesPosition(5), point(972, 469));
    assert.deepEqual(pad.getDealerPosition(1), point(41, 384.5));
    assert.throws(() => pad.getPosition(DealtCard.toPlayer(6, null, 1)));

    const phone = new IPhoneLayout();
    assert.equal(phone.numberOfAIPlayers, 4);
    assert.deepEqual(phone.getPosition(DealtCard.toPlayer(4, null, 1)), point(757.5, 145));
    //On the phone the dealer token of the two left hand seats is on the inside
    assert.deepEqual(phone.getDealerPosition(1), point(266, 145));
    assert.deepEqual(phone.getDealerPosition(4), point(705, 145));
    assert.throws(() => phone.getPosition(DealtCard.toPlayer(5, null, 1)));

    assert.deepEqual(new StartLayout(true).cardPosition(2), point(491, 210));
    assert.deepEqual(new StartLayout(false).cardPosition(0), point(487, 400));
});

//MARK: - Setting up and dealing

test('Set up: mats, names and lives for every seat, the game is counted, and the dealer is announced', () => {
    const { view, model, settings } = createGame();
    assert.equal(model.school.players.length, 6);
    assert.deepEqual(view.callsTo('addTableMat').map(args => args[0]), [-1, 0, 1, 2, 3, 4, 5]);
    assert.deepEqual(view.callsTo('addName').map(args => args[0]), ['Middle', ...model.school.players.map(player => player.name)]);
    assert.equal(view.callsTo('addLives').length, 6);
    assert.equal(settings.gamesPlayed, 1);
    assert.equal(view.lastMessage, `${model.school.dealer.name}\nDealing`);
    assert.deepEqual(view.callsTo('updateDealer'), [[model.school.dealer]]);
    //All the cards are gathered to the deck, face down
    assert.equal(view.callsTo('setPosition').length, 52);
    assert.ok([...view.faceUp.values()].every(isFaceUp => !isFaceUp));
});

test('Set up: the phone layout has four computer players and no name for the middle', () => {
    const { view, model } = createGame({ layout: new IPhoneLayout() });
    assert.equal(model.school.players.length, 5);
    assert.ok(!view.callsTo('addName').some(args => args[0] === 'Middle'));
});

test('Dealing: the cards go to their places, then the human\'s hand and two of the middle are face up', () => {
    const game = createGame();
    const { view, model, presenter } = game;
    game.runUntil(() => model.gameState === GameState.turnStart);
    const layout = presenter.tableLayout;
    model.middle.hand.forEach((card, i) => {
        assert.deepEqual(view.positions.get(card), layout.getPosition(DealtCard.toMiddle(card, i + 1)));
        assert.equal(view.faceUp.get(card), i !== 0);
        assert.equal(view.zPositions.get(card), Layer.card1 + i);
    });
    for (const player of model.school.players) {
        player.hand.hand.forEach((card, i) => {
            assert.deepEqual(view.positions.get(card), layout.getPosition(DealtCard.toPlayer(player.seat, card, i + 1)));
            assert.equal(view.faceUp.get(card), player.seat === 0);
        });
    }
    //The rest of the deck is hidden
    assert.ok(model.deck.deck.every(card => view.zPositions.get(card) === -1));
});

//MARK: - The human's turn

test('Human turn: touching cards lifts them, a hand card and a middle card make the swap', () => {
    const game = createGame();
    const { view, model, presenter } = game;
    game.runUntilHumansTurn();
    assert.equal(view.lastMessage, 'Your Turn');
    const human = model.school.playerHuman;
    assert.deepEqual(view.callsTo('highlight').at(-1), [human, PlayerStatus.turn]);
    const handCard = human.hand.hand[1];
    const middleCard = model.middle.hand[2];
    const home = presenter.tableLayout.getPosition(DealtCard.toPlayer(0, handCard, 2));

    //A computer player's card cannot be touched
    presenter.handleTouch(model.school.players[1].hand.hand[0]);
    assert.equal(model.selectedCards.length, 0);

    presenter.handleTouch(handCard);
    assert.deepEqual(view.positions.get(handCard), point(home.x, home.y + 50));
    assert.equal(view.sounds.at(-1), 'card');
    //Touching it again puts it back
    presenter.handleTouch(handCard);
    assert.deepEqual(view.positions.get(handCard), home);
    assert.equal(model.selectedCards.length, 0);

    presenter.handleTouch(handCard);
    presenter.handleTouch(middleCard);
    //The move is made: the cards change places
    assert.equal(model.isPlayersTurn, false);
    assert.equal(model.selectedCards.length, 0);
    assert.equal(human.hand.hand[1], middleCard);
    assert.equal(model.middle.hand[2], handCard);
    assert.deepEqual(view.positions.get(middleCard), home);
    assert.deepEqual(view.positions.get(handCard), presenter.tableLayout.getPosition(DealtCard.toMiddle(handCard, 3)));
    assert.equal(view.faceUp.get(middleCard), true);
    assert.equal(view.faceUp.get(handCard), true);
    assert.deepEqual(view.callsTo('highlight').at(-1), [human, PlayerStatus.played]);
    //Touches are ignored now
    presenter.handleTouch(human.hand.hand[0]);
    assert.equal(model.selectedCards.length, 0);
});

test('Human turn: all three cards, the first one touched goes face down in the middle', () => {
    const game = createGame();
    const { view, model, presenter } = game;
    game.runUntilHumansTurn();
    const human = model.school.playerHuman;
    const [h1, h2, h3] = human.hand.hand;
    const oldMiddle = [...model.middle.hand];
    presenter.handleTouch(h2);
    presenter.handleTouch(h3);
    //Two hand cards are lifted, so a middle card cannot be picked
    presenter.handleTouch(oldMiddle[1]);
    assert.equal(model.selectedCards.length, 2);
    presenter.handleTouch(h1);
    assert.deepEqual(human.hand.hand, oldMiddle);
    assert.deepEqual(model.middle.hand, [h2, h1, h3]);
    assert.equal(view.faceUp.get(h2), false);
    assert.equal(view.faceUp.get(h1), true);
    assert.equal(view.faceUp.get(h3), true);
    oldMiddle.forEach(card => assert.equal(view.faceUp.get(card), true));
});

test('Human turn: hints are shown in turn while the player thinks', () => {
    const game = createGame();
    game.runUntilHumansTurn();
    game.runUntil(() => game.view.lastMessage === 'Or Select 3 Cards\nTo swap them all');
    assert.deepEqual(game.view.messages.slice(-4), ['Your Turn', 'Select 1 Card\nFrom Your Hand', 'Then 1 Card\nFrom The Middle', 'Or Select 3 Cards\nTo swap them all']);
});

test('Standard game: the action buttons stay disabled', () => {
    const game = createGame();
    game.runUntilHumansTurn();
    assert.deepEqual(game.view.buttons, { looky: 'disabled', stashHand: 'disabled', changeMiddle: 'disabled' });
    game.presenter.handleAction(TurnAction.looky);
    assert.equal(game.view.faceUp.get(game.model.middle.hand[0]), false);
});

//MARK: - Looky Looky actions

test('Looky Looky: looky turns the face down card over until the move is made', () => {
    const game = createGame({ lookyLooky: true });
    const { view, model, presenter } = game;
    game.runUntilHumansTurn();
    assert.deepEqual(view.buttons, { looky: 'enabled', stashHand: 'enabled', changeMiddle: 'enabled' });
    const down = model.middle.hand[0];
    presenter.handleAction(TurnAction.looky);
    assert.equal(view.faceUp.get(down), true);
    assert.equal(view.buttons.looky, ActionButtonState.disabled);
    assert.equal(view.buttons.stashHand, ActionButtonState.enabled);

    presenter.handleTouch(model.school.playerHuman.hand.hand[0]);
    presenter.handleTouch(model.middle.hand[1]);
    assert.equal(view.faceUp.get(down), false);
    assert.deepEqual(view.buttons, { looky: 'disabled', stashHand: 'disabled', changeMiddle: 'disabled' });
});

test('Looky Looky: stash hand deals three new cards face up, lifted cards are put back first', () => {
    const game = createGame({ lookyLooky: true });
    const { view, model, presenter } = game;
    game.runUntilHumansTurn();
    const human = model.school.playerHuman;
    const old = [...human.hand.hand];
    presenter.handleTouch(old[0]);
    presenter.handleAction(TurnAction.stashHand);
    assert.equal(model.selectedCards.length, 0);
    for (const card of old) {
        assert.equal(view.faceUp.get(card), false);
        assert.deepEqual(view.positions.get(card), presenter.tableLayout.deckPosition);
    }
    human.hand.hand.forEach((card, i) => {
        assert.ok(!old.includes(card));
        assert.equal(view.faceUp.get(card), true);
        assert.deepEqual(view.positions.get(card), presenter.tableLayout.getPosition(DealtCard.toPlayer(0, card, i + 1)));
    });
    assert.equal(view.buttons.stashHand, ActionButtonState.disabled);
});

test('Looky Looky: change a middle card, pick the card after pressing the button, pressing again cancels', () => {
    const game = createGame({ lookyLooky: true });
    const { view, model, presenter } = game;
    game.runUntilHumansTurn();
    presenter.handleAction(TurnAction.changeMiddle);
    assert.equal(presenter.isChoosingMiddleCard, true);
    assert.equal(view.buttons.changeMiddle, ActionButtonState.selected);
    assert.equal(view.lastMessage, 'Pick a middle\ncard to change');
    //The prompt stays while the player chooses
    game.run(30);
    assert.equal(view.lastMessage, 'Pick a middle\ncard to change');
    //A hand card is not a choice
    presenter.handleTouch(model.school.playerHuman.hand.hand[0]);
    assert.equal(presenter.isChoosingMiddleCard, true);
    assert.equal(model.selectedCards.length, 0);
    //Cancel
    presenter.handleAction(TurnAction.changeMiddle);
    assert.equal(presenter.isChoosingMiddleCard, false);
    assert.equal(view.buttons.changeMiddle, ActionButtonState.enabled);
    assert.equal(view.lastMessage, 'Your Turn');

    //Change the face down card: its replacement is face down too
    const down = model.middle.hand[0];
    presenter.handleAction(TurnAction.changeMiddle);
    presenter.handleTouch(down);
    const replacement = model.middle.hand[0];
    assert.notEqual(replacement, down);
    assert.equal(view.faceUp.get(replacement), false);
    assert.deepEqual(view.positions.get(replacement), presenter.tableLayout.getPosition(DealtCard.toMiddle(replacement, 1)));
    assert.deepEqual(view.positions.get(down), presenter.tableLayout.deckPosition);
    assert.equal(view.buttons.changeMiddle, ActionButtonState.disabled);
    assert.equal(presenter.isChoosingMiddleCard, false);

    //Two actions is the limit
    presenter.handleAction(TurnAction.looky);
    presenter.handleAction(TurnAction.stashHand);
    assert.deepEqual(view.buttons, { looky: 'disabled', stashHand: 'disabled', changeMiddle: 'disabled' });
    assert.equal(model.actionsTaken.length, 2);
});

test('Looky Looky: a computer player\'s actions are announced, and its cards stay face down', () => {
    //The human plays random moves, in case they are first to go
    const game = createGame({ lookyLooky: true, autoPlay: true });
    const { view, model } = game;
    //Every computer player looks, so wait for the first one to
    game.runUntil(() => view.messages.some(message => message.endsWith('\nLooky Looky')));
    const player = model.currentPlayer;
    assert.notEqual(player.seat, 0);
    assert.equal(view.lastMessage, `${player.name}\nLooky Looky`);
    assert.equal(view.faceUp.get(model.middle.hand[0]), false);
    assert.equal(game.presenter.gameUpdateFrequency, 1.5);
    player.hand.hand.forEach(card => assert.equal(view.faceUp.get(card), false));
});

//MARK: - End of the round and of the game

/** Gives a player the hand, so the round ends as wanted: each card is swapped with wherever it is now */
function rig(model, player, hand) {
    const everyone = [model.middle, ...model.school.players.map(p => p.hand)];
    hand.forEach((card, i) => {
        const old = player.hand.hand[i];
        const holder = everyone.find(h => h.hand.includes(card));
        if (holder) {
            holder.replace(card, old);
        } else {
            model.deck.remove(card);
            model.deck.receive([old]);
        }
        player.hand.hand[i] = card;
    });
}

test('End of round: the loser is named, their lives shown, and the game waits for the continue button', () => {
    const game = createGame();
    const { view, model, presenter } = game;
    game.runUntilEveryoneHasPlayed();
    //The human has the lowest hand there is, everyone else a pair
    const pairs = [['ac', 'ad', '7h'], ['kc', 'kd', '8h'], ['qc', 'qd', '9h'], ['jc', 'jd', 'th'], ['tc', 'td', '6h']];
    model.school.players.forEach((player, i) => rig(model, player, cards(...(i === 0 ? ['2s', '3h', '5d'] : pairs[i - 1]))));
    //The cards go back to the deck once the round is scored, so note them now
    const onTheTable = [model.middle.hand[0], ...model.school.players.flatMap(player => player.hand.hand)];
    assert.equal(onTheTable.length, 19);
    game.runUntil(() => view.isContinueShowing);
    //Every hand and the face down card have been turned over
    assert.ok(view.messages.includes('End of Round\nWorst Hand Loses'));
    onTheTable.forEach(card => assert.equal(view.faceUp.get(card), true));
    assert.equal(view.lastMessage, 'You lose a life');
    assert.equal(model.school.playerHuman.lives, 2);
    assert.deepEqual(view.callsTo('updateScore'), [[model.school.playerHuman]]);
    assert.equal(view.sounds.at(-1), 'LoseLife');
    //Nothing happens until continue is pressed
    const calls = view.calls.length;
    game.run(30);
    assert.equal(view.calls.length, calls);
    presenter.continueGame();
    assert.equal(view.isContinueShowing, false);
    assert.equal(view.lastMessage, '');
    game.runUntil(() => view.lastMessage.endsWith('\nDealing'));
});

test('End of round, Looky Looky: a first winning prial gains a life, with a yahoo', () => {
    const game = createGame({ lookyLooky: true });
    const { view, model } = game;
    game.runUntilEveryoneHasPlayed();
    //The highest hand there is
    rig(model, model.school.playerHuman, PrialOfThrees);
    game.runUntil(() => view.isContinueShowing);
    assert.equal(view.lastMessage, 'Prial! You\ngain a life');
    assert.deepEqual(view.callsTo('extraLife'), [[model.school.playerHuman]]);
    assert.equal(model.school.playerHuman.lives, 4);
    assert.ok(view.sounds.includes('Yahoo'));
    assert.ok(!view.sounds.includes('LoseLife'));
});

test('A whole game plays itself to the end, standard rules', () => {
    const game = createGame({ autoPlay: true });
    const { view, model, settings } = game;
    game.runUntil(() => view.dialog !== null, 100000);
    assert.equal(model.school.players.length, 1);
    const winner = model.school.players[0];
    assert.equal(view.lastMessage, winner.seat === 0 ? 'You are the\nWinner' : `${winner.name} is the\nWinner`);
    assert.equal(view.dialog.title, 'STATS');
    assert.equal(settings.gamesPlayed, 1);
    assert.equal(settings.gamesWon, winner.seat === 0 ? 1 : 0);
    assert.ok(view.dialog.message.includes(`Games Won:  ${settings.gamesWon}`));
    //Everyone else was removed from the table
    assert.equal(view.callsTo('removePlayer').length, 5);
    assert.ok(view.sounds.includes('ricochet') || view.sounds.includes('sad_whistle'));
});

test('A whole game plays itself to the end, Looky Looky rules on the phone layout', () => {
    const game = createGame({ autoPlay: true, lookyLooky: true, layout: new IPhoneLayout() });
    const { view, model } = game;
    game.runUntil(() => view.dialog !== null, 100000);
    assert.equal(model.school.players.length, 1);
    assert.equal(view.callsTo('removePlayer').length, 4);
    assert.ok(view.messages.some(message => message.endsWith('\nLooky Looky')));
    //Every card the view was told about is a real card, and none was left lifted
    assert.equal(model.selectedCards.length, 0);
});

test('Quit: the view is told and the presenter lets go of it', () => {
    const game = createGame();
    const { view, presenter, model } = game;
    presenter.quit();
    assert.equal(view.hasQuit, true);
    assert.equal(view.sounds.at(-1), 'sad_whistle');
    assert.equal(presenter.view, null);
    assert.equal(model.gameListener, null);
});

//MARK: - Start screen

test('Start screen: each example hand is dealt, turned, spread, named and gathered in turn', () => {
    const presenter = new StartPresenter(true);
    const view = new FakeStartView();
    presenter.view = view;
    assert.equal(presenter.deck.count, 52);
    presenter.next();
    const first = presenter.examples[0];
    //Three cards are dealt one after the other
    assert.deepEqual(view.calls, [['setZ', first.hand[0], Layer.card1], ['actionMove', first.hand[0], point(441, 210), 0.25]]);
    while (view.names().at(-1) !== 'actionWait') {
        assert.ok(view.step());
    }
    assert.deepEqual(view.names(), ['setZ', 'actionMove', 'setZ', 'actionMove', 'setZ', 'actionMove',
        'actionTurnCard', 'actionTurnCard', 'actionTurnCard', 'actionSpread', 'actionFadeInName', 'actionWait']);
    assert.deepEqual(view.calls.at(-2), ['actionFadeInName', '5 Stinking High', 2.0]);
    assert.deepEqual(view.calls.find(call => call[0] === 'actionSpread'), ['actionSpread', first.hand, 50]);

    //After the wait the hand is gathered and the next one dealt
    view.calls.length = 0;
    for (let i = 0; i < 4; i++) {
        view.step();
    }
    assert.deepEqual(view.names(), ['actionGather', 'actionFadeOutName', 'actionGather', 'actionGather', 'setZ', 'actionMove']);
    assert.equal(view.calls.at(-1)[1], presenter.examples[1].hand[0]);

    //It goes round all the examples and starts again
    for (let i = 0; i < 34 * 11; i++) {
        view.step();
    }
    assert.equal(presenter.exampleIndex, 1);
});
