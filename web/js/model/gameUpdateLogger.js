// Ported from CrazyBrag/model/GameUpdateLogger.swift
import { Turn, TurnAction } from './defines.js';

/** A game listener that writes what happens in the game as text, to the console unless given another log function */
export class GameUpdateLogger {
    constructor(log = console.log) {
        this.log = log;
    }

    dealerSelected(dealer) {
        this.log(`\n${dealer.name} is Dealing`);
    }

    dealingDone(dealtCards) {
        this.log('Dealing done');
    }

    reveal() {
        this.log('Reveal');
    }

    turnStarted(player, middle) {
        this.log(`Turn: ${player.name}(${player.lives}): \t${player.hand.display()}.    Middle: ${middle.display()}`);
    }

    actionTaken(player, action) {
        switch (action.action) {
            case TurnAction.looky:
                this.log(`Actn: ${player.name} looks at ${action.card.display()}`);
                break;
            case TurnAction.stashHand:
                this.log(`Actn: ${player.name} stashes ${action.discarded.map(card => card.display()).join('_')}, now holds ${player.hand.display()}`);
                break;
            default:
                this.log(`Actn: ${player.name} changes ${action.discarded.display()} in the middle for ${action.dealt.card.display()}`);
        }
    }

    turnEnded(player, middle, turn) {
        this.log(`TEnd: ${player.name}(${player.lives}): \t${player.hand.display()}.    Middle: ${middle.display()}.   ${Turn.display(turn)}`);
    }

    showHands(players) {
        this.log('Resolving hands, what has everyone got?');
        players.forEach(player => this.log(`${player.name} \t${player.hand.display()}`));
    }

    roundEnded(losingPlayers, extraLife) {
        this.log(`End of Round, losing players: ${this.concatenatePlayerNames(losingPlayers)}`);
        if (extraLife) {
            this.log(`Extra life for ${extraLife.name}`);
        }
    }

    pullThePeg(outPlayers) {
        if (outPlayers.length > 0) {
            this.log(`Pull the peg!: ${this.concatenatePlayerNames(outPlayers)}`);
        }
    }

    everyoneOutSoReplayRound() {
        this.log('There can only be one! Have another round');
    }

    gameOver(winner) {
        this.log(`Winner is ${winner.name} with ${winner.lives} lives remaining`);
    }

    concatenatePlayerNames(players) {
        return players.map(player => player.name + ', ').join('');
    }
}
