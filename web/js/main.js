// Starts the game on the page's canvas.
// For testing, options can be put in the address: index.html?autoplay=1&layout=phone&speed=10
import { App } from './view/app.js';

const params = new URLSearchParams(globalThis.location.search);
const app = new App(document.getElementById('game'), {
    autoplay: params.get('autoplay') === '1',
    layout: params.get('layout'),
    speed: Number(params.get('speed') ?? 1),
});
//So the game can be poked from the browser's console
globalThis.crazyBrag = app;
app.start();
