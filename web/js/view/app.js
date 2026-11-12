// The web game: owns the canvas, loads the assets, runs the frame loop and passes pointer presses to the scene
import { Settings } from '../settings.js';
import { IPadLayout, IPhoneLayout } from '../presenter/layout.js';
import { Assets } from './assets.js';
import { Sounds } from './audio.js';
import { GameScene } from './gameScene.js';

/** Wider than this (width / height) and the wide table of the iPhone is used, otherwise the 4:3 table of the iPad */
const WIDE_ASPECT = 1.7;

export class App {
    /**
     * canvas: the canvas element to draw on, it is sized to fill its parent
     * options: {autoplay: the human seat plays itself, layout: 'phone' or 'pad' instead of choosing by the window's shape,
     *           speed: how many times faster than normal the game runs}
     */
    constructor(canvas, options = {}) {
        this.canvas = canvas;
        this.options = options;
        this.ctx = canvas.getContext('2d');
        this.settings = new Settings();
        this.assets = new Assets();
        this.sounds = new Sounds();
        this.scene = null;
        this.loaded = 0;
        this.error = null;
        this.lastFrame = null;
        this.view = { scale: 1, x: 0, y: 0 };

        canvas.addEventListener('pointerdown', event => this.pointer(event, 'pointerDown'));
        canvas.addEventListener('pointerup', event => this.pointer(event, 'pointerUp'));
        canvas.addEventListener('pointercancel', () => this.scene?.stage.pointerCancel());
        canvas.addEventListener('contextmenu', event => event.preventDefault());
        globalThis.addEventListener('resize', () => this.resize());
        this.resize();
    }

    async start() {
        requestAnimationFrame(now => this.frame(now));
        this.sounds.load();
        try {
            await this.assets.load(fraction => { this.loaded = fraction; });
            this.startGame();
        } catch (error) {
            this.error = error;
            console.error(error);
        }
    }

    get isWide() {
        if (this.options.layout) {
            return this.options.layout === 'phone';
        }
        return this.canvas.clientWidth / this.canvas.clientHeight >= WIDE_ASPECT;
    }

    startGame() {
        this.scene = new GameScene(this, this.isWide ? new IPhoneLayout() : new IPadLayout());
        this.scene.presenter.autoPlayEnabled = Boolean(this.options.autoplay);
        this.resize();
    }

    /** The player has quit the game. For now a new game starts, until there is a start screen to go back to */
    gameQuit() {
        this.startGame();
    }

    //MARK: - Size and pointer

    /** The canvas has as many pixels as the screen gives it, the scene is scaled to fit and centred */
    resize() {
        const ratio = globalThis.devicePixelRatio ?? 1;
        const width = this.canvas.clientWidth, height = this.canvas.clientHeight;
        this.canvas.width = Math.round(width * ratio);
        this.canvas.height = Math.round(height * ratio);
        const size = this.scene?.stage.size ?? { width, height };
        const scale = Math.min(width / size.width, height / size.height);
        this.view = { scale, x: (width - size.width * scale) / 2, y: (height - size.height * scale) / 2, ratio };
    }

    pointer(event, handler) {
        this.sounds.unlock();
        const stage = this.scene?.stage;
        if (!stage) {
            return;
        }
        const bounds = this.canvas.getBoundingClientRect();
        const x = (event.clientX - bounds.left - this.view.x) / this.view.scale;
        const y = stage.size.height - (event.clientY - bounds.top - this.view.y) / this.view.scale;
        stage[handler](x, y);
        event.preventDefault();
    }

    //MARK: - Frames

    frame(now) {
        const seconds = now / 1000;
        //After the page has been in the background a long time has passed, do not try to catch up
        const dt = (this.lastFrame === null ? 0 : Math.min(0.1, seconds - this.lastFrame)) * (this.options.speed ?? 1);
        this.lastFrame = seconds;
        try {
            this.scene?.update(dt);
            this.draw();
        } catch (error) {
            this.error = error;
            console.error(error);
        }
        requestAnimationFrame(next => this.frame(next));
    }

    draw() {
        const { ctx, canvas } = this;
        const { scale, x, y, ratio } = this.view;
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.fillStyle = '#1c130a';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        if (!this.scene) {
            this.drawLoading();
            return;
        }
        const size = this.scene.stage.size;
        ctx.setTransform(scale * ratio, 0, 0, scale * ratio, x * ratio, y * ratio);
        ctx.save();
        ctx.beginPath();
        ctx.rect(0, 0, size.width, size.height);
        ctx.clip();
        this.scene.stage.draw(ctx);
        ctx.restore();
    }

    drawLoading() {
        const { ctx, canvas } = this;
        const ratio = this.view.ratio ?? 1;
        ctx.fillStyle = '#f5e3ad';
        ctx.font = `${20 * ratio}px Georgia, serif`;
        ctx.textAlign = 'center';
        const text = this.error ? 'Sorry, the game could not be loaded' : `Loading ${Math.round(this.loaded * 100)}%`;
        ctx.fillText(text, canvas.width / 2, canvas.height / 2);
    }
}
