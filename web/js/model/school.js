// Ported from CrazyBrag/model/School.swift
import { Player } from './player.js';
import { HumanAI } from './ai.js';
import { OneDownAI } from './oneDownAI.js';
import { BragHandTypes, maxBy, minBy, randomElement, shuffled } from './defines.js';

/** The players round the table: who deals, who is next, and who loses a life */
export class School {
    constructor() {
        this.players = [];
        this.dealer = null;
        this.humanAI = new HumanAI();
        this.playerBomber = new Player('Bomber', new OneDownAI());
        this.playerChris = new Player('Chris', new OneDownAI());
        this.playerHolly = new Player('Pig Dog', new OneDownAI());
        this.playerHowie = new Player('Howie', new OneDownAI());
        this.playerGeordie = new Player('Geordie', new OneDownAI());
        this.playerHuman = new Player('You', this.humanAI);
    }

    get getAllPlayers() {
        return [this.playerChris, this.playerHowie, this.playerHolly, this.playerBomber, this.playerGeordie];
    }

    setUpPlayers(numberOfAIPlayers) {
        //Human player is seat position 0
        this.players = [this.playerHuman, ...shuffled(this.getAllPlayers).slice(0, numberOfAIPlayers)];
        //Set up lives and seat positions
        this.players.forEach((player, seat) => {
            player.lives = 3;
            player.hasHadExtraLife = false;
            player.seat = seat;
        });
        this.dealer = randomElement(this.players);
    }

    /**
     * The next player is the seat after the current player (the player's left / clockwise).
     * If no seats left, start back round at the lowest seat, like a circular buffer
     */
    nextPlayer(current) {
        const after = this.players.filter(player => player.seat > current.seat);
        return minBy(after.length > 0 ? after : this.players, player => player.seat) ?? null;
    }

    sortPlayersInDealOrder() {
        const dealerSeat = this.dealer?.seat ?? 0;
        const bySeat = (a, b) => a.seat - b.seat;
        const after = this.players.filter(player => player.seat > dealerSeat).sort(bySeat);
        const before = this.players.filter(player => player.seat <= dealerSeat).sort(bySeat);
        return [...after, ...before];
    }

    nextDealer() {
        if (this.dealer) {
            this.dealer = this.nextPlayer(this.dealer) ?? this.dealer;
        }
    }

    getPlayer(name) {
        return this.players.find(player => player.name === name) ?? null;
    }

    stashCards(deck) {
        for (const player of this.players) {
            deck.receive(player.hand.stash());
        }
    }

    resolveHands() {
        this.players.forEach(player => player.resolveHand());
    }

    isPrialOut() {
        return this.players.some(player => player.score.type === BragHandTypes.prial);
    }

    /** Needed to find the player with the largest prial */
    highestScoringPlayer() {
        return maxBy(this.players, player => player.score.score) ?? null;
    }

    /**
     * Looky Looky rules: the first winning prial a player plays earns them an extra life
     * instead of costing everyone else a life, after that their prials work as usual.
     * Call after resolveHands(), returns the player given the life, or null if there isn't one.
     * If more than one prial is out, only the highest wins.
     */
    awardExtraLife() {
        const winner = this.isPrialOut() ? this.highestScoringPlayer() : null;
        if (!winner || winner.hasHadExtraLife) {
            return null;
        }
        winner.hasHadExtraLife = true;
        winner.lives = winner.lives + 1;
        return winner;
    }

    /**
     * The players who lose a life, null if there are no players.
     * bulletProof: Looky Looky rules, a player holding a trotter or a prial does not lose a life to a winning prial
     */
    determineLosingHands(bulletProof = false) {
        if (this.players.length === 0) {
            return null;
        }
        if (this.isPrialOut()) {
            const topPlayer = this.highestScoringPlayer();
            //"Prial out, everyone (else) out!" cries the top player
            return this.players
                .filter(player => player.name !== topPlayer.name)
                .filter(player => !(bulletProof && player.score.type >= BragHandTypes.trotter));
        }
        const lowest = Math.min(...this.players.map(player => player.score.score));
        return this.players.filter(player => player.score.score === lowest);
    }

    playersWithNoLivesLeft() {
        return this.players.filter(player => player.lives === 0);
    }

    removePlayersWithNoLivesLeft() {
        this.players = this.players.filter(player => player.lives > 0);
    }

    areAllPlayersOut() {
        return this.players.every(player => player.lives === 0);
    }

    /**
     * If all players had the same hand and so are all out then no one has won the game,
     * so this round needs to be replayed, give the remaining players 1 life back.
     */
    reinstatePlayers() {
        this.players.forEach(player => { player.lives = 1; });
    }
}
