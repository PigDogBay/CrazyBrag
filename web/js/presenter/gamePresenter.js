// Ported from CrazyBrag/GamePresenter.swift and GameView.swift
import { Model } from '../model/model.js';
import { TurnAction } from '../model/defines.js';
import { GameUpdateLogger } from '../model/gameUpdateLogger.js';
import { Settings } from '../settings.js';
import { point, zPosition } from './layout.js';
import * as States from './playStates.js';

export const PlayerStatus = States.PlayerStatus;

export const ActionButtonState = Object.freeze({
    /** The action cannot be taken at the moment */
    disabled: 'disabled',
    enabled: 'enabled',
    /** The button has been pressed and is waiting for the player to pick a card */
    selected: 'selected',
});

/**
 * Runs the game on the table: listens to the model, and for each thing that happens switches to a play state
 * that drives the view (animations, messages, sounds) and decides how long to wait before moving the model on.
 *
 * The view is the only thing the presenter and the states talk to, it implements:
 *   quit()
 *   setZPosition(card, z)                    drawing order of a card
 *   setPosition(card, pos, duration, delay)  move a card, times in seconds
 *   turn(card, isFaceUp)
 *   addName(name, pos), addLives(name, pos), addTableMat(seat)
 *   updateScore(player)                      show the player's lives
 *   extraLife(player)                        celebrate the life the player has gained
 *   updateDealer(player), removePlayer(player)
 *   highlight(player, status)                a PlayerStatus
 *   show(message)                            the status text, "" clears it
 *   play(soundName)
 *   continueButton(show)                     pressing it calls presenter.continueGame()
 *   discard(card, pos, duration)             move a stashed card back to the deck and out of sight
 *   setActionButton(action, state)           Looky Looky rules: an ActionButtonState for a TurnAction's button
 *   showMessage(title, message)              optional, a dialog for the player's stats at the end of the game
 * Card touches go to handleTouch(card), action buttons to handleAction(action), and update(seconds) is called every frame.
 */
export class GamePresenter {
    /**
     * tableLayout: an IPadLayout or IPhoneLayout, which also sets the number of computer players
     * settings: the player's Settings
     * log: true to write the game to the console as it is played
     */
    constructor({ tableLayout, settings = new Settings(), log = false }) {
        this.tableLayout = tableLayout;
        this.settings = settings;
        this.model = new Model();
        this.logger = log ? new GameUpdateLogger() : null;
        this.view = null;
        this.lastGameUpdateTime = 0;
        /** Seconds between calls to the play state's update(), each state sets it */
        this.gameUpdateFrequency = 0.5;
        this.playState = new States.NullState();
        /** Looky Looky rules: the player has pressed the change a middle card button and now has to pick the card */
        this.isChoosingMiddleCard = false;
        /** For testing: the human seat plays random moves and presses continue, so a game runs unattended */
        this.autoPlayEnabled = false;
    }

    change(state) {
        this.playState.exit();
        this.playState = state;
        state.enter();
    }

    setUpGame(view) {
        this.view = view;
        this.model.lookyLooky = this.settings.lookyLooky;
        this.model.setUpGame(this.tableLayout.numberOfAIPlayers);
        this.model.gameListener = this;
        this.model.updateState();
        //increase game count
        this.settings.gamesPlayed = this.settings.gamesPlayed + 1;
        if (!this.tableLayout.isPhone) {
            view.addName('Middle', this.tableLayout.getNamePosition(-1));
        }
        view.addTableMat(-1);
        for (const player of this.model.school.players) {
            view.addTableMat(player.seat);
            view.addName(player.name, this.tableLayout.getNamePosition(player.seat));
            view.addLives(player.name, this.tableLayout.getLivesPosition(player.seat));
        }
    }

    /** The continue button has been pressed */
    continueGame() {
        this.model.updateState();
    }

    quit() {
        this.model.gameListener = null;
        this.view?.quit();
        this.view?.play('sad_whistle');
        this.view = null;
    }

    /** Call every frame with the time in seconds */
    update(currentTime) {
        if ((currentTime - this.lastGameUpdateTime) > this.gameUpdateFrequency) {
            this.playState.update();
            this.lastGameUpdateTime = currentTime;
        }
    }

    /** Plays a random move for the human */
    autoPlay() {
        const human = this.model.school.players.find(player => player.seat === 0);
        if (human) {
            this.handleTouch(human.hand.hand[Math.floor(Math.random() * 3)]);
            this.handleTouch(this.model.middle.hand[Math.floor(Math.random() * 3)]);
        }
    }

    /** Moves the DealtCards to their places, one after the other. Middle cards are face up, except the first */
    positionCard(cards, duration) {
        let delay = 0.0;
        for (const dealt of cards) {
            const isFaceUp = dealt.isMiddle && dealt.cardCount !== 1;
            this.view?.turn(dealt.card, isFaceUp);
            this.view?.setZPosition(dealt.card, zPosition(dealt));
            this.view?.setPosition(dealt.card, this.tableLayout.getPosition(dealt), duration, delay);
            delay = delay + 0.1;
        }
    }

    /** Turns the cards of a PlayerHand face up. The hand of a player who is out of the game is empty */
    showCards(hand) {
        if (hand.hand.length !== 3 && hand.hand.length !== 0) {
            throw new Error(`Hand does NOT contain 3 cards ${hand.hand.length}`);
        }
        for (const card of hand.hand) {
            this.view?.turn(card, true);
        }
    }

    //MARK: - Touch handling

    /** The player has touched a card */
    handleTouch(card) {
        const model = this.model;
        if (this.isChoosingMiddleCard) {
            //The touch picks the middle card to change
            if (model.middle.hand.includes(card)) {
                this.isChoosingMiddleCard = false;
                model.takeChangeMiddle(card);
                this.view?.show('Your Turn');
                this.refreshActionButtons();
            }
            return;
        }
        const dealtCard = model.toTouchableCard(card);
        if (dealtCard) {
            if (model.selectedCards.some(selected => selected.card === card)) {
                this.deselectCard(dealtCard);
            } else if (model.validate(dealtCard)) {
                this.selectCard(dealtCard);
                this.checkIfFinishedTurn();
            }
        }
    }

    checkIfFinishedTurn() {
        const turn = this.model.checkIfSwapped() ?? this.model.checkIfAllIn();
        if (turn) {
            this.model.school.humanAI.turn = turn;
            this.model.updateState();
            this.model.selectedCards = [];
        }
    }

    /** A selected card is lifted towards the centre of the table */
    selectCard(dealt) {
        this.model.selectedCards.push(dealt);
        this.view?.play('card');
        this.moveCard(dealt, dealt.seat === 0 ? 50.0 : -50.0);
    }

    deselectCard(dealt) {
        this.model.selectedCards = this.model.selectedCards.filter(selected => selected.card !== dealt.card);
        this.moveCard(dealt, 0);
    }

    deselectAllCards() {
        for (const dealt of this.model.selectedCards) {
            this.moveCard(dealt, 0);
        }
        this.model.selectedCards = [];
    }

    //MARK: - Looky Looky actions

    /** The player has pressed one of the action buttons */
    handleAction(action) {
        const model = this.model;
        if (!model.isPlayersTurn) {
            return;
        }
        switch (action) {
            case TurnAction.looky:
                this.cancelChoosingMiddleCard();
                model.takeLooky();
                break;
            case TurnAction.stashHand:
                this.cancelChoosingMiddleCard();
                if (model.canTake(TurnAction.stashHand)) {
                    this.deselectAllCards();
                    model.takeStashHand();
                }
                break;
            case TurnAction.changeMiddle:
                if (this.isChoosingMiddleCard) {
                    //Pressing the button again cancels
                    this.cancelChoosingMiddleCard();
                } else if (model.canTake(TurnAction.changeMiddle)) {
                    this.deselectAllCards();
                    this.isChoosingMiddleCard = true;
                    this.view?.play('card');
                    this.view?.show('Pick a middle\ncard to change');
                }
                break;
        }
        this.refreshActionButtons();
    }

    cancelChoosingMiddleCard() {
        if (this.isChoosingMiddleCard) {
            this.isChoosingMiddleCard = false;
            this.view?.show('Your Turn');
        }
    }

    /** Show which of the actions the human player can take right now */
    refreshActionButtons() {
        if (!this.model.isPlayersTurn) {
            this.isChoosingMiddleCard = false;
        }
        for (const action of TurnAction.allCases) {
            let state = ActionButtonState.disabled;
            if (this.isChoosingMiddleCard && action === TurnAction.changeMiddle) {
                state = ActionButtonState.selected;
            } else if (this.model.isPlayersTurn && this.model.canTake(action)) {
                state = ActionButtonState.enabled;
            }
            this.view?.setActionButton(action, state);
        }
    }

    /** Stashed cards go back to the deck, face down */
    discard(cards) {
        for (const card of cards) {
            this.view?.turn(card, false);
            this.view?.discard(card, this.tableLayout.deckPosition, 0.4);
        }
    }

    moveCard(dealt, yOffset) {
        const pos = this.tableLayout.getPosition(dealt);
        this.view?.setPosition(dealt.card, point(pos.x, pos.y + yOffset), 0.2, 0);
    }

    //MARK: - GameListener functions

    dealerSelected(dealer) {
        this.logger?.dealerSelected(dealer);
        this.change(new States.DealerSelectedState(this, dealer));
    }

    dealingDone(dealtCards) {
        this.logger?.dealingDone(dealtCards);
        this.change(new States.DealingDoneState(this, dealtCards));
    }

    reveal() {
        this.logger?.reveal();
        this.change(new States.RevealState(this));
    }

    turnStarted(player, middle) {
        this.logger?.turnStarted(player, middle);
        if (player.seat === 0) {
            this.change(new States.HumanTurnStartedState(this, player, middle));
        } else {
            this.change(new States.TurnStartedState(this, player, middle));
        }
    }

    /** Not a new play state, the turn carries on once the action has been shown */
    actionTaken(player, action) {
        this.logger?.actionTaken(player, action);
        const isHuman = player.seat === 0;
        this.view?.play('card');
        if (!isHuman) {
            //Leave time to read what the computer player is doing before their next step
            this.gameUpdateFrequency = 1.5;
        }
        switch (action.action) {
            case TurnAction.looky:
                if (isHuman) {
                    //Only the human player gets to see the card, it is turned back over when their turn ends
                    this.view?.turn(action.card, true);
                } else {
                    this.view?.show(`${player.name}\nLooky Looky`);
                }
                break;
            case TurnAction.stashHand:
                this.discard(action.discarded);
                this.positionCard(action.dealt, 0.3);
                if (isHuman) {
                    this.showCards(player.hand);
                } else {
                    this.view?.show(`${player.name}\nStashes hand`);
                }
                break;
            case TurnAction.changeMiddle:
                this.discard([action.discarded]);
                this.positionCard([action.dealt], 0.3);
                if (!isHuman) {
                    this.view?.show(`${player.name}\nChanges a card`);
                }
                break;
        }
    }

    turnEnded(player, middle, turn) {
        this.logger?.turnEnded(player, middle, turn);
        this.change(new States.TurnEndedState(this, player, middle, turn));
    }

    showHands(players) {
        this.logger?.showHands(players);
        this.change(new States.ShowHandsState(this, players));
    }

    roundEnded(losingPlayers, extraLife) {
        this.logger?.roundEnded(losingPlayers, extraLife);
        this.change(new States.EndOfRoundState(this, losingPlayers, extraLife));
    }

    pullThePeg(outPlayers) {
        this.logger?.pullThePeg(outPlayers);
        this.change(new States.PullThePegState(this, outPlayers));
    }

    everyoneOutSoReplayRound() {
        this.logger?.everyoneOutSoReplayRound();
        this.change(new States.EveryoneOutSoReplayRoundState(this));
    }

    gameOver(winner) {
        this.logger?.gameOver(winner);
        this.change(new States.GameOverState(this, winner));
    }
}
