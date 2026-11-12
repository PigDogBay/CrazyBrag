// Ported from CrazyBrag/view/StartScene.swift: the title screen, with the example hands being dealt,
// and the DEAL, HELP and GAME buttons. It is the view the StartPresenter talks to.
import { StartPresenter } from '../presenter/startPresenter.js';
import { InformationLayout, Layer } from '../presenter/layout.js';
import { Stage } from './stage.js';
import { BackgroundNode, ButtonNode, CardNode, LabelNode } from './nodes.js';
import { InformationNode, SettingsNode } from './panels.js';

const MUSIC = 'honky-tonk';

export class StartScene {
    /** app: gives the assets, sounds and settings, and is told when the player wants a game */
    constructor(app, isPhone) {
        this.app = app;
        this.isPhone = isPhone;
        this.presenter = new StartPresenter(isPhone);
        const layout = this.layout = this.presenter.startLayout;
        this.stage = new Stage(layout.size);
        this.panel = null;

        this.stage.add(new BackgroundNode(app.assets.image('westerntown'))).z = Layer.background;
        const title = this.stage.add(new LabelNode({ text: 'Crazy Brag', size: layout.titleFontSize, baseline: 'alphabetic' }));
        title.at(layout.titlePos).z = Layer.messages;
        this.handName = this.stage.add(new LabelNode({ size: layout.nameFontSize, baseline: 'alphabetic' }));
        this.handName.at(layout.namePos).z = Layer.messages;
        this.handName.alpha = 0;

        this.cardNodes = new Map();
        this.presenter.deck.deck.forEach((card, index) => {
            const node = this.stage.add(new CardNode(card, app.assets, layout.cardSize, app.settings.markedDeck));
            node.at(layout.deckPos).z = Layer.deck + index;
            this.cardNodes.set(card, node);
        });

        this.addButton('DEAL', layout.dealButtonPos, () => this.startGame());
        this.addButton('HELP', layout.rulesButtonPos, () => this.showInstructions());
        this.addButton('GAME', layout.settingsButtonPos, () => this.showSettings());

        //Fade the music in after a moment (and once the browser allows any sound)
        this.stage.after(1.0, () => app.sounds.startMusic(MUSIC));
        this.presenter.view = this;
        this.presenter.next();
    }

    update(dt) {
        this.stage.update(dt);
    }

    addButton(label, pos, onPressed) {
        const button = this.stage.add(new ButtonNode(label, this.layout.buttonFontSize, onPressed));
        button.at(pos).z = Layer.ui;
        return button;
    }

    startGame() {
        this.app.sounds.stopMusic();
        this.app.sounds.play('ricochet', 0.15);
        this.app.showGame();
    }

    /** Only one panel at a time, the rules or the settings */
    showPanel(panel) {
        if (this.panel) {
            return null;
        }
        this.panel = this.stage.add(panel);
        panel.onClose = () => { this.panel = null; };
        return panel;
    }

    showInstructions() {
        return this.showPanel(new InformationNode(new InformationLayout(this.isPhone)));
    }

    showSettings() {
        return this.showPanel(new SettingsNode(new InformationLayout(this.isPhone), this.app.settings, () => {
            //The deck has been changed, show the new backs
            this.cardNodes.forEach(node => node.setDeck(this.app.settings.markedDeck));
        }));
    }

    //MARK: - StartView

    setZ(card, z) {
        this.cardNodes.get(card).z = z;
    }

    actionMove(card, pos, duration, completion) {
        this.stage.animate(this.cardNodes.get(card), { x: pos.x, y: pos.y }, duration, { then: completion });
    }

    actionTurnCard(card, duration, completion) {
        this.stage.after(duration, () => {
            this.cardNodes.get(card).isFaceUp = true;
            completion();
        });
    }

    actionGather(card, pos, duration, completion) {
        const node = this.cardNodes.get(card);
        node.isFaceUp = false;
        node.rotation = 0.0;
        this.stage.animate(node, { x: pos.x, y: pos.y }, duration, { then: completion });
    }

    /** Fans the three cards out */
    actionSpread(hand, byX, completion) {
        const [left, middle, right] = hand.map(card => this.cardNodes.get(card));
        const duration = 0.25;
        const angle = Math.PI / 12.0;
        this.stage.animate(left, { x: left.x - byX, rotation: angle }, duration);
        this.stage.animate(middle, { y: middle.y + byX / 4 }, duration);
        this.stage.animate(right, { x: right.x + byX, rotation: -angle }, duration, { then: completion });
    }

    actionWait(duration, completion) {
        this.stage.after(duration, completion);
    }

    actionFadeInName(name, duration) {
        this.handName.text = name;
        this.stage.animate(this.handName, { alpha: 1 }, duration);
    }

    actionFadeOutName(duration) {
        this.stage.animate(this.handName, { alpha: 0 }, duration);
    }
}
