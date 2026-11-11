// Plays Looky Looky games between computer players that take the actions and players that do not,
// to see what the actions are worth. Not a test:  node tests/tournament.js [games]
import { Model, GameState } from '../js/model/model.js';
import { OneDownAI } from '../js/model/oneDownAI.js';
import { Player } from '../js/model/player.js';
import { randomElement, shuffled } from '../js/model/defines.js';

const games = Number(process.argv[2] ?? 3000);
const wins = { actions: 0, noActions: 0 };
for (let game = 0; game < games; game++) {
    const model = new Model();
    model.lookyLooky = true;
    model.setUpGame(5);
    const players = shuffled([0, 1, 2, 3, 4, 5].map(i => {
        const ai = new OneDownAI();
        ai.usesActions = i % 2 === 0;
        return new Player(`P${i}`, ai);
    }));
    players.forEach((player, seat) => { player.seat = seat; });
    model.school.players = players;
    model.school.dealer = randomElement(players);
    while (model.gameState !== GameState.gameOver) {
        model.updateState();
    }
    wins[model.school.players[0].ai.usesActions ? 'actions' : 'noActions'] += 1;
}
console.log(`actions: ${wins.actions}  no actions: ${wins.noActions}  of ${games}`);
