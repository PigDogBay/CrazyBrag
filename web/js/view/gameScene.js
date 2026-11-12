// Ported from CrazyBrag/view/GameScene.swift: the table. It is the view the GamePresenter talks to.
import { GamePresenter, PlayerStatus } from '../presenter/gamePresenter.js';
import { InformationLayout, Layer, point } from '../presenter/layout.js';
import { TurnAction } from '../model/defines.js';
import { Stage } from './stage.js';
import {
    ActionButtonNode, BackgroundNode, ButtonNode, CardNode, Colours, DialogNode, LabelNode, LivesNode, MatNode,
    MessageNode, ParticleNode,
} from './nodes.js';

export class GameScene {
    /**
     * app: gives the assets, sounds and settings, and is told when the player quits
     * tableLayout: an IPadLayout or IPhoneLayout
     */
    constructor(app, tableLayout) {
        this.app = app;
        this.layout = tableLayout;
        this.stage = new Stage(tableLayout.size);
        this.presenter = new GamePresenter({ tableLayout, settings: app.settings });
        this.cardNodes = new Map();
        this.livesNodes = new Map();
        this.actionButtons = new Map();
        this.time = 0;
        this.markedDeck = app.settings.markedDeck;

        this.stage.add(new BackgroundNode(app.assets.image('westerntown'))).z = Layer.background;
        this.dealerToken = this.stage.add(new LabelNode({ text: '⭐️', font: 'emoji', size: tableLayout.fonts.dealerFontSize, align: 'right' }));
        this.dealerToken.at(tableLayout.getDealerPosition(0)).z = Layer.ui;
        this.messageNode = this.stage.add(new MessageNode(tableLayout.fonts.statusFontSize));
        this.messageNode.at(tableLayout.message).z = Layer.messages;
        this.addBackButton();

        this.presenter.setUpGame(this);
        if (this.presenter.model.lookyLooky) {
            this.addActionButtons();
            //The presenter sets the buttons at the start of each turn, until then they cannot be pressed
            this.presenter.refreshActionButtons();
        }
    }

    /** Called every frame with the seconds since the last one */
    update(dt) {
        this.time += dt;
        this.presenter?.update(this.time);
        this.stage.update(dt);
    }

    /** The node for a card, made the first time the card is used: face down on the deck */
    cardNode(card) {
        let node = this.cardNodes.get(card);
        if (!node) {
            node = new CardNode(card, this.app.assets, this.layout.cardSize, this.markedDeck);
            node.at(this.layout.deckPosition).z = Layer.deck;
            node.onDown = () => this.presenter?.handleTouch(card);
            this.stage.add(node);
            this.cardNodes.set(card, node);
        }
        return node;
    }

    //MARK: - GameView

    quit() {
        this.presenter = null;
        this.app.gameQuit();
    }

    setZPosition(card, z) {
        this.cardNode(card).z = z;
    }

    setPosition(card, pos, duration, delay) {
        this.stage.animate(this.cardNode(card), { x: pos.x, y: pos.y }, duration, { delay });
    }

    discard(card, pos, duration) {
        const node = this.cardNode(card);
        this.stage.stopAnimations(node);
        //Hide behind the background, like the rest of the deck
        this.stage.animate(node, { x: pos.x, y: pos.y }, duration, { then: () => { node.z = -1.0; } });
    }

    setActionButton(action, state) {
        this.actionButtons.get(action)?.show(state);
    }

    turn(card, isFaceUp) {
        this.cardNode(card).isFaceUp = isFaceUp;
    }

    /** The player's lives as hearts. The grey heart of the extra life goes once it is won, or the player is out */
    showLives(node, player) {
        node.lives = player.lives;
        node.showExtraLife = this.presenter.model.lookyLooky && !player.hasHadExtraLife && player.lives > 0;
    }

    updateScore(player) {
        const node = this.livesNodes.get(player.name);
        if (node) {
            this.showLives(node, player);
            this.showParticles('explosion', node);
            this.highlightLoser(player);
        }
    }

    /** Looky Looky rules: the player has gained a life */
    extraLife(player) {
        const node = this.livesNodes.get(player.name);
        if (node) {
            this.showLives(node, player);
            this.stage.animate(node, { scale: 1.6 }, 0.25, { yoyo: true, repeat: 3 });
        }
    }

    updateDealer(player) {
        const pos = this.layout.getDealerPosition(player.seat);
        this.stage.animate(this.dealerToken, { x: pos.x, y: pos.y }, 0.5);
    }

    removePlayer(player) {
        this.stage.find(`name ${player.name}`)?.remove();
        this.stage.find(`table mat ${player.seat}`)?.remove();
        const frame = this.layout.getFrame(player.seat);
        this.showParticles('fire', point(frame.midX, frame.y));
    }

    highlight(player, status) {
        const node = this.stage.find(`table mat ${player.seat}`);
        if (!node) {
            return;
        }
        switch (status) {
            case PlayerStatus.ready:
                node.fill = 'gray';
                node.alpha = 0.25;
                node.glow = 0;
                break;
            case PlayerStatus.turn:
                node.fill = 'rgb(0, 255, 0)';
                node.alpha = 0.55;
                node.glow = 5;
                this.stage.animate(node, { scale: 1.2 }, 0.25, { yoyo: true });
                break;
            case PlayerStatus.played:
                node.fill = 'red';
                node.alpha = 0.25;
                node.glow = 0;
                break;
        }
    }

    addName(name, pos) {
        const label = this.stage.add(new LabelNode({ text: name, size: this.layout.fonts.nameFontSize, align: 'left' }));
        label.name = `name ${name}`;
        label.at(pos).z = Layer.ui;
    }

    addLives(name, pos) {
        const node = this.stage.add(new LivesNode(this.layout.fonts.livesFontSize, this.presenter.model.lookyLooky));
        node.at(pos).z = Layer.ui;
        this.livesNodes.set(name, node);
    }

    addTableMat(seat) {
        const frame = this.layout.getFrame(seat);
        //Centred on the middle of the frame so that the scale animation is centred
        const node = this.stage.add(new MatNode(frame.width + 16, frame.height + 16));
        node.name = `table mat ${seat}`;
        node.at(point(frame.midX, frame.midY)).z = Layer.tableMat;
        node.alpha = 0.5;
    }

    show(message) {
        this.messageNode.show(message);
    }

    play(soundName) {
        this.app.sounds.play(soundName);
    }

    continueButton(show) {
        this.stage.find('continue')?.remove();
        if (!show) {
            return;
        }
        const button = this.stage.add(new ButtonNode('Continue', this.layout.fonts.buttonFontSize, () => this.presenter?.continueGame()));
        button.name = 'continue';
        button.at(this.layout.continueButton).z = Layer.continueButton;
        button.fill = Colours.continueButton;
        button.attract();
    }

    /** The player's stats at the end of the game */
    showMessage(title, message) {
        const dialog = this.stage.add(new DialogNode(new InformationLayout(this.layout.isPhone), title, message));
        dialog.name = `dialog ${title}`;
    }

    //MARK: - Misc

    showParticles(kind, pos) {
        this.stage.add(new ParticleNode(kind)).at(pos).z = Layer.particles;
    }

    /** The loser's mat flashes */
    highlightLoser(player) {
        const node = this.stage.find(`table mat ${player.seat}`);
        if (node) {
            this.stage.animate(node, { alpha: 1.0 }, 0.25, {
                then: () => this.stage.animate(node, { alpha: 0.2 }, 0.25, { yoyo: true, repeat: 4 }),
            });
        }
    }

    /** Looky Looky rules: the three action buttons next to the player's hand */
    addActionButtons() {
        const images = [[TurnAction.looky, 'ActionLooky'], [TurnAction.stashHand, 'ActionStash'], [TurnAction.changeMiddle, 'ActionChange']];
        images.forEach(([action, imageName], index) => {
            const button = new ActionButtonNode(this.app.assets.image(imageName), this.layout.actionButtonSize,
                () => this.presenter?.handleAction(action));
            button.at(this.layout.actionButtons[index]).z = Layer.ui;
            this.stage.add(button);
            this.actionButtons.set(action, button);
        });
    }

    addBackButton() {
        const button = this.stage.add(new ButtonNode('QUIT', this.layout.fonts.buttonFontSize, () => this.presenter?.quit()));
        button.at(this.layout.backButton).z = Layer.ui;
    }
}
