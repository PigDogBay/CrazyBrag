// Ported from the *State.swift files of CrazyBrag
//
// A play state shows one step of the game: enter() drives the view and sets presenter.gameUpdateFrequency,
// update() is then called on that interval and usually moves the model on to its next step.
// States that wait for the player (end of round, game over) do not move on in update().
import { DealtCard } from '../model/defines.js';
import { Stats } from '../model/stats.js';
import { Layer } from './layout.js';

/** How a player's cards are highlighted: waiting, taking their turn, or having played */
export const PlayerStatus = Object.freeze({ ready: 'ready', turn: 'turn', played: 'played' });

export class NullState {
    enter() {}
    update() {}
    exit() {}
}

class BasePlayState {
    constructor(presenter) {
        this.presenter = presenter;
    }
    get view() {
        return this.presenter.view;
    }
    get model() {
        return this.presenter.model;
    }
    enter() {}
    /** By default move the game on */
    update() {
        this.model.updateState();
    }
    exit() {}
}

export class DealerSelectedState extends BasePlayState {
    constructor(presenter, dealer) {
        super(presenter);
        this.dealer = dealer;
    }

    allCardsToDeck() {
        const pos = this.presenter.tableLayout.deckPosition;
        let z = Layer.deck;
        for (const card of this.model.deck.deck) {
            this.view?.setZPosition(card, z);
            this.view?.turn(card, false);
            z = z + 1;
            this.view?.setPosition(card, pos, 0.5, 0);
        }
    }

    enter() {
        this.view?.show(`${this.dealer.name}\nDealing`);
        this.presenter.gameUpdateFrequency = 1.0;
        this.view?.updateDealer(this.dealer);
        this.allCardsToDeck();
        for (const player of this.model.school.players) {
            this.view?.highlight(player, PlayerStatus.ready);
        }
    }
}

export class DealingDoneState extends BasePlayState {
    constructor(presenter, dealtCards) {
        super(presenter);
        this.dealtCards = dealtCards;
    }

    enter() {
        this.presenter.gameUpdateFrequency = 2.5;
        this.presenter.positionCard(this.dealtCards, 0.1);
    }
}

export class RevealState extends BasePlayState {
    enter() {
        this.presenter.showCards(this.model.school.playerHuman.hand);
        //Hide the deck
        for (const card of this.model.deck.deck) {
            this.view?.setZPosition(card, -1.0);
        }
    }
}

/** Computer player's turn */
export class TurnStartedState extends BasePlayState {
    constructor(presenter, player, middle) {
        super(presenter);
        this.player = player;
        this.middle = middle;
    }

    enter() {
        this.presenter.gameUpdateFrequency = 1;
        this.view?.highlight(this.player, PlayerStatus.turn);
        this.view?.show(`${this.player.name}'s\nTurn`);
    }
}

/** Waits for the player to make their move, showing hints in turn */
export class HumanTurnStartedState extends BasePlayState {
    constructor(presenter, player, middle) {
        super(presenter);
        this.player = player;
        this.middle = middle;
        this.counter = 0;
    }

    enter() {
        this.presenter.gameUpdateFrequency = 1;
        this.view?.highlight(this.player, PlayerStatus.turn);
        //Player can now interact with the cards
        this.model.isPlayersTurn = true;
        this.view?.show('Your Turn');
        this.presenter.refreshActionButtons();
    }

    update() {
        if (this.presenter.isChoosingMiddleCard) {
            //Leave the prompt to pick a middle card on screen
            this.counter = 0;
            return;
        }
        this.counter = this.counter + 1;
        switch (this.counter) {
            case 1:
                if (this.presenter.autoPlayEnabled) {
                    this.presenter.autoPlay();
                }
                break;
            case 5:
                this.view?.show('Select 1 Card\nFrom Your Hand');
                break;
            case 9:
                this.view?.show('Then 1 Card\nFrom The Middle');
                break;
            case 13:
                this.view?.show('Or Select 3 Cards\nTo swap them all');
                break;
            case 17:
                this.counter = 0;
                this.view?.show('Your Turn');
                break;
        }
    }
}

export class TurnEndedState extends BasePlayState {
    constructor(presenter, player, middle, turn) {
        super(presenter);
        this.player = player;
        this.middle = middle;
        this.turn = turn;
    }

    enter() {
        const { presenter, player, middle, turn } = this;
        presenter.gameUpdateFrequency = 2.5;
        this.model.isPlayersTurn = false;
        presenter.refreshActionButtons();
        //Looky Looky rules: the player may have looked at the face down card, which is always first in the middle
        if (middle.hand.length > 0) {
            this.view?.turn(middle.hand[0], false);
        }
        if (turn.kind === 'swap') {
            //The player and middle hands will already be swapped in the model
            //however on screen they need to be moved
            //First find the index of the new card in the players hand
            const pIndex = player.hand.indexOf(turn.middle);
            //Then find the index of the discarded card in the middle
            const mIndex = middle.indexOf(turn.hand);
            if (pIndex !== -1 && mIndex !== -1) {
                //Move the cards to their new positions
                presenter.positionCard([
                    DealtCard.toPlayer(player.seat, turn.middle, pIndex + 1),
                    DealtCard.toMiddle(turn.hand, mIndex + 1),
                ], 0.5);
            }
        } else {
            //All the cards need swapping
            presenter.positionCard([
                ...player.hand.hand.map((card, i) => DealtCard.toPlayer(player.seat, card, i + 1)),
                ...middle.hand.map((card, i) => DealtCard.toMiddle(card, i + 1)),
            ], 0.5);
        }
        if (player.seat === 0) {
            presenter.showCards(this.model.school.playerHuman.hand);
        }
        this.view?.highlight(player, PlayerStatus.played);
    }
}

export class ShowHandsState extends BasePlayState {
    constructor(presenter, players) {
        super(presenter);
        this.players = players;
    }

    enter() {
        this.view?.show('End of Round\nWorst Hand Loses');
        this.presenter.gameUpdateFrequency = 2.5;
        for (const player of this.model.school.players) {
            this.presenter.showCards(player.hand);
        }
        //Reveal the face down middle card
        if (this.model.middle.hand.length > 0) {
            this.view?.turn(this.model.middle.hand[0], true);
        }
    }
}

/** Waits for the human player to press the continue button */
export class EndOfRoundState extends BasePlayState {
    /** extraLife: Looky Looky rules, the player who has gained a life for their first winning prial, or null */
    constructor(presenter, losingPlayers, extraLife) {
        super(presenter);
        this.losingPlayers = losingPlayers;
        this.extraLife = extraLife;
        this.counter = 0;
    }

    enter() {
        const { losingPlayers, extraLife } = this;
        switch (losingPlayers.length) {
            case 0:
                //Looky Looky rules: a prial won, but everyone else held a trotter or a prial
                this.view?.show(extraLife ? '' : 'Bullet proof\nNo lives lost');
                break;
            case 1:
                this.view?.show(losingPlayers[0].seat === 0 ? 'You lose a life' : `${losingPlayers[0].name}\nLoses a life`);
                break;
            default:
                this.view?.show(`${losingPlayers.length} Players\nLose a life`);
        }
        for (const player of losingPlayers) {
            this.view?.updateScore(player);
        }
        if (extraLife) {
            this.view?.show(extraLife.seat === 0 ? 'Prial! You\ngain a life' : `Prial! ${extraLife.name}\ngains a life`);
            this.view?.extraLife(extraLife);
            this.view?.play('Yahoo');
        }
        if (losingPlayers.length > 0) {
            this.view?.play('LoseLife');
        }
        //Player must press the continue button
        this.view?.continueButton(true);
        this.presenter.gameUpdateFrequency = 0.5;
    }

    update() {
        this.counter = this.counter + 1;
        if (this.presenter.autoPlayEnabled && this.counter === 5) {
            this.presenter.continueGame();
        }
    }

    exit() {
        this.view?.play('card');
        this.view?.continueButton(false);
    }
}

export class PullThePegState extends BasePlayState {
    constructor(presenter, outPlayers) {
        super(presenter);
        this.outPlayers = outPlayers;
    }

    enter() {
        const { outPlayers } = this;
        this.presenter.gameUpdateFrequency = 2.5;
        switch (outPlayers.length) {
            case 0:
                this.view?.show('');
                break;
            case 1:
                if (outPlayers[0].seat === 0) {
                    this.view?.show('You are out');
                    this.view?.play('sad_whistle');
                } else {
                    this.view?.show(`${outPlayers[0].name}\nIs Out`);
                    this.view?.play('ricochet');
                }
                break;
            default:
                this.view?.play('ricochet');
                this.view?.show(`${outPlayers.length} Players\nAre Out`);
        }
        for (const player of outPlayers) {
            this.view?.removePlayer(player);
        }
    }
}

export class EveryoneOutSoReplayRoundState extends BasePlayState {
    enter() {
        this.view?.show('A Draw\nDeal Again');
    }
}

/** The end of the game: shows the winner and the player's stats, nothing more happens until the player quits */
export class GameOverState extends BasePlayState {
    constructor(presenter, winner) {
        super(presenter);
        this.winner = winner;
    }

    enter() {
        const settings = this.presenter.settings;
        if (this.winner.seat === 0) {
            //increase win count
            settings.gamesWon = settings.gamesWon + 1;
            this.view?.show('You are the\nWinner');
        } else {
            this.view?.show(`${this.winner.name} is the\nWinner`);
        }
        const stats = new Stats(settings.gamesPlayed, settings.gamesWon);
        this.view?.showMessage?.('STATS', stats.summary());
    }

    update() {}
}
