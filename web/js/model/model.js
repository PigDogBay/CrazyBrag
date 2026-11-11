// Ported from CrazyBrag/model/Model.swift
import { Deck } from './deck.js';
import { PlayerHand } from './playerHand.js';
import { School } from './school.js';
import { HandRules } from './playingCard.js';
import { DealtCard, Turn, TurnAction, TurnActionResult } from './defines.js';

export const GameState = Object.freeze({
    setUp: 'setUp', selectDealer: 'selectDealer', deal: 'deal', reveal: 'reveal', turnStart: 'turnStart', turnEnd: 'turnEnd',
    showHands: 'showHands', scoreRound: 'scoreRound', updateLives: 'updateLives', gameOver: 'gameOver',
});

/**
 * The game, a state machine: each call to updateState() performs exactly one step and reports it
 * to the gameListener. The model never advances itself, something else must keep calling updateState().
 *
 * The gameListener may implement any of: dealerSelected(dealer), dealingDone(dealtCards), reveal(),
 * turnStarted(player, middle), actionTaken(player, action), turnEnded(player, middle, turn), showHands(players),
 * roundEnded(losingPlayers, extraLife), pullThePeg(outPlayers), everyoneOutSoReplayRound(), gameOver(winner)
 */
export class Model {
    /** Looky Looky rules: the most actions a player may take before making their move */
    static maxActionsPerTurn = 2;

    constructor() {
        this.deck = new Deck();
        this.middle = new PlayerHand();
        this.school = new School();
        this.gameState = GameState.setUp;
        this.gameListener = null;
        this.nextPlayer = null;
        /** The DealtCards the human player has picked so far for their move */
        this.selectedCards = [];
        this.isPlayersTurn = false;
        /** Game mode: play with the extra Looky Looky rules */
        this.lookyLooky = false;
        /** The actions the current player has taken this turn */
        this.actionsTaken = [];
    }

    /** The player whose turn it is */
    get currentPlayer() {
        return this.nextPlayer;
    }

    updateState() {
        switch (this.gameState) {
            case GameState.setUp:
                this.setUpGame(5);
                break;
            case GameState.selectDealer:
                this.school.nextDealer();
                this.deck.shuffle();
                this.gameState = GameState.deal;
                this.gameListener?.dealerSelected?.(this.school.dealer);
                break;
            case GameState.deal: {
                const dealt = this.deal();
                this.gameState = GameState.reveal;
                //Next Player will be moved on in turnStart
                this.nextPlayer = this.school.dealer;
                this.gameListener?.dealingDone?.(dealt);
                break;
            }
            case GameState.reveal:
                this.gameState = GameState.turnStart;
                this.gameListener?.reveal?.();
                break;
            case GameState.turnStart:
                this.turnStart();
                break;
            case GameState.turnEnd:
                this.turnEnd();
                break;
            case GameState.showHands:
                this.gameState = GameState.scoreRound;
                this.gameListener?.showHands?.(this.school.players);
                break;
            case GameState.scoreRound:
                this.scoreRound();
                this.stashAll();
                break;
            case GameState.updateLives:
                this.updateLives();
                break;
            case GameState.gameOver:
                this.gameOver();
                break;
        }
    }

    setUpGame(numberOfAIPlayers) {
        this.deck.hasJokers = this.lookyLooky;
        HandRules.deucesWild = this.lookyLooky;
        this.deck.createDeck();
        this.deck.shuffle();
        this.school.setUpPlayers(numberOfAIPlayers);
        this.gameState = GameState.selectDealer;
    }

    /** All the cards go back to the deck. Throws if a card has been duplicated or dropped */
    stashAll() {
        this.school.stashCards(this.deck);
        this.deck.receive(this.middle.stash());
        if (this.deck.count !== this.deck.max) {
            throw new Error(`Dropped a card, ${this.deck.count} in the deck`);
        }
    }

    deal() {
        const dealActions = [];
        //Deal 3 cards each and 3 in the middle
        for (let i = 1; i <= 3; i++) {
            for (const player of this.school.sortPlayersInDealOrder()) {
                const card = this.deck.deal();
                dealActions.push(DealtCard.toPlayer(player.seat, card, i));
                player.hand.receive(card);
            }
            const card = this.deck.deal();
            this.middle.receive(card);
            dealActions.push(DealtCard.toMiddle(card, i));
        }
        return dealActions;
    }

    turnStart() {
        this.nextPlayer = this.school.nextPlayer(this.nextPlayer);
        this.actionsTaken = [];
        //Set the state first, the listener asks which actions the player can take
        this.gameState = GameState.turnEnd;
        this.gameListener?.turnStarted?.(this.nextPlayer, this.middle);
    }

    turnEnd() {
        if (this.nextPlayer && this.takeChosenAction(this.nextPlayer)) {
            //A computer player has taken an action, stay in this state until they make their move
            return;
        }
        const turn = this.nextPlayer.play(this.middle);
        //Dealer is last player
        this.gameState = this.nextPlayer === this.school.dealer ? GameState.showHands : GameState.turnStart;
        this.gameListener?.turnEnded?.(this.nextPlayer, this.middle, turn);
    }

    //MARK: - Looky Looky actions

    /**
     * Can the current player take the action? Only in a Looky Looky game, after their turn has started and
     * before they make their move, each action once a turn and no more than two of the three.
     */
    canTake(action) {
        return this.lookyLooky
            && this.gameState === GameState.turnEnd
            && this.nextPlayer !== null
            && this.actionsTaken.length < Model.maxActionsPerTurn
            && !this.actionsTaken.includes(action);
    }

    taken(result) {
        this.actionsTaken.push(result.action);
        this.gameListener?.actionTaken?.(this.nextPlayer, result);
    }

    /**
     * Looky Looky rules: let the player's AI take one action, if it wants to.
     * Returns true if an action was taken (the human takes their actions through the take functions)
     */
    takeChosenAction(player) {
        const available = TurnAction.allCases.filter(action => this.canTake(action));
        if (available.length === 0) {
            return false;
        }
        const choice = player.ai.chooseAction(this.middle, available);
        if (!choice || !available.includes(choice.action)) {
            return false;
        }
        switch (choice.action) {
            case TurnAction.looky: {
                const card = this.takeLooky();
                if (card === null) {
                    return false;
                }
                player.ai.lookedAt(card);
                return true;
            }
            case TurnAction.stashHand:
                return this.takeStashHand();
            default:
                return this.takeChangeMiddle(choice.card);
        }
    }

    /**
     * The current player looks at the face down card in the middle.
     * Returns the card, or null if the action is not allowed
     */
    takeLooky() {
        if (!this.canTake(TurnAction.looky) || this.middle.hand.length === 0) {
            return null;
        }
        const card = this.middle.hand[0];
        this.taken(TurnActionResult.looky(card));
        return card;
    }

    /**
     * The current player stashes their hand and is dealt three new cards.
     * Stashed cards go to the bottom of the deck. Returns false if the action is not allowed
     */
    takeStashHand() {
        if (!this.canTake(TurnAction.stashHand)) {
            return false;
        }
        const player = this.nextPlayer;
        const discarded = player.hand.stash();
        const dealt = [];
        for (let i = 1; i <= 3; i++) {
            const card = this.deck.deal();
            player.hand.receive(card);
            dealt.push(DealtCard.toPlayer(player.seat, card, i));
        }
        this.deck.receive(discarded);
        this.taken(TurnActionResult.stashHand(discarded, dealt));
        return true;
    }

    /**
     * The current player stashes one of the cards in the middle, a new card is dealt in its place.
     * The first card of the middle is the face down card, its replacement is also face down.
     * Returns false if the action is not allowed or the card is not in the middle
     */
    takeChangeMiddle(card) {
        if (!this.canTake(TurnAction.changeMiddle) || !this.middle.hand.includes(card)) {
            return false;
        }
        const index = this.middle.indexOf(card);
        const newCard = this.deck.deal();
        this.middle.replace(card, newCard);
        this.deck.receive([card]);
        this.taken(TurnActionResult.changeMiddle(card, DealtCard.toMiddle(newCard, index + 1)));
        return true;
    }

    /** Find the losing hand and lose the player a life */
    scoreRound() {
        this.school.resolveHands();
        this.gameState = GameState.updateLives;
        if (this.lookyLooky) {
            const extraLifePlayer = this.school.awardExtraLife();
            if (extraLifePlayer) {
                //Looky Looky: the prial has earned an extra life, so this round nobody loses a life
                this.gameListener?.roundEnded?.([], extraLifePlayer);
                return;
            }
        }
        const losingPlayers = this.school.determineLosingHands(this.lookyLooky);
        if (losingPlayers) {
            losingPlayers.forEach(player => { player.lives = player.lives - 1; });
            if (this.school.areAllPlayersOut()) {
                //Oops no one won, so play another round
                this.school.reinstatePlayers();
                //Don't update lives, start another deal
                this.gameState = GameState.selectDealer;
                this.gameListener?.everyoneOutSoReplayRound?.();
            } else {
                this.gameListener?.roundEnded?.(losingPlayers, null);
            }
        }
    }

    updateLives() {
        const pegPullers = this.school.playersWithNoLivesLeft();
        this.school.removePlayersWithNoLivesLeft();
        this.gameState = this.school.players.length < 2 ? GameState.gameOver : GameState.selectDealer;
        //Notify view of which players are out
        this.gameListener?.pullThePeg?.(pegPullers);
    }

    gameOver() {
        const winner = this.school.players[0];
        if (winner) {
            winner.gamesWon += 1;
            this.gameListener?.gameOver?.(winner);
        }
    }

    //MARK: - The human player's selection

    /** If the card can be interacted with by the user, converts the PlayingCard into a DealtCard, otherwise null */
    toTouchableCard(card) {
        const handIndex = this.school.playerHuman.hand.indexOf(card);
        if (handIndex !== -1) {
            return DealtCard.toPlayer(0, card, handIndex + 1);
        }
        const middleIndex = this.middle.indexOf(card);
        if (middleIndex !== -1) {
            return DealtCard.toMiddle(card, middleIndex + 1);
        }
        return null;
    }

    /** The turn if the player has selected all of their cards to throw in, the first card selected is down */
    checkIfAllIn() {
        const fromHand = this.selectedCards.filter(dealt => !dealt.isMiddle);
        if (fromHand.length === 3) {
            const index = this.school.playerHuman.hand.indexOf(fromHand[0].card);
            if (index !== -1) {
                return Turn.all(index);
            }
        }
        return null;
    }

    /** The turn if the player has selected one of their cards and one middle card */
    checkIfSwapped() {
        const playerCard = this.selectedCards.find(dealt => !dealt.isMiddle);
        const middleCard = this.selectedCards.find(dealt => dealt.isMiddle);
        if (this.selectedCards.length !== 2 || !playerCard || !middleCard) {
            return null;
        }
        return Turn.swap(playerCard.card, middleCard.card);
    }

    /** Check if the player's selection is valid: true valid, false invalid */
    validate(selectedCard) {
        //Only allow selection when it is the player's turn
        if (!this.isPlayersTurn) {
            return false;
        }
        const middleCount = this.selectedCards.filter(dealt => dealt.isMiddle).length;
        const handCount = this.selectedCards.length - middleCount;
        //Only 1 card in the middle can be selected
        if (selectedCard.isMiddle && middleCount > 0) {
            return false;
        }
        //Cannot select the middle if two hand cards already selected
        if (selectedCard.isMiddle && handCount === 2) {
            return false;
        }
        return true;
    }
}
