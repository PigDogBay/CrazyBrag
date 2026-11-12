// The things that are drawn on the stage: cards, labels, buttons, table mats, particles.
// Each draws itself around 0,0 in ordinary canvas coordinates (y down), see stage.js.
import { Node } from './stage.js';
import { BODY_FONT, EMOJI_FONT, QUENTIN_CAPS, cardBackImageName, cardImageName } from './assets.js';

export const Colours = Object.freeze({
    rulesBackground: 'rgba(62, 39, 35, 0.95)',
    continueButton: 'rgb(253, 241, 169)',
});

export function roundedRect(ctx, x, y, width, height, radius) {
    ctx.beginPath();
    ctx.roundRect(x, y, width, height, radius);
}

/** The background picture, scaled to fill the stage and pinned to its bottom edge, so a wide stage crops the top */
export class BackgroundNode extends Node {
    constructor(image) {
        super();
        this.image = image;
    }

    drawSelf(ctx, stage) {
        const { width, height } = stage.size;
        const scale = Math.max(width / this.image.width, height / this.image.height);
        const w = this.image.width * scale, h = this.image.height * scale;
        //The node is at the bottom left of the stage
        ctx.drawImage(this.image, (width - w) / 2, -h, w, h);
    }
}

/** A playing card: one image for its face and one for its back */
export class CardNode extends Node {
    constructor(card, assets, cardSize, markedDeck) {
        super();
        this.card = card;
        this.assets = assets;
        this.width = cardSize.width;
        this.height = cardSize.height;
        this.isFaceUp = false;
        this.front = assets.image(cardImageName(card));
        this.setDeck(markedDeck);
    }

    /** Changes the back of the card to the marked or the plain deck */
    setDeck(markedDeck) {
        this.back = this.assets.image(cardBackImageName(this.card, markedDeck));
    }

    contains(x, y) {
        return Math.abs(x) <= this.width / 2 && Math.abs(y) <= this.height / 2;
    }

    drawSelf(ctx) {
        ctx.imageSmoothingQuality = 'high';
        ctx.drawImage(this.isFaceUp ? this.front : this.back, -this.width / 2, -this.height / 2, this.width, this.height);
    }
}

/**
 * Text, of one or more lines.
 * font: 'title' (Quentin Caps), 'body' or 'emoji'
 * align: 'left', 'center' or 'right' of the node's position
 * baseline: 'bottom' the last line sits on the position, 'middle' the block is centred on it
 * stroke: a colour to outline the letters with
 * lineSpacing: extra space between lines
 */
export class LabelNode extends Node {
    constructor({ text = '', font = 'title', size = 20, colour = 'black', align = 'center', baseline = 'bottom', stroke = null, lineSpacing = 0 } = {}) {
        super();
        this.text = text;
        this.font = font;
        this.size = size;
        this.colour = colour;
        this.align = align;
        this.baseline = baseline;
        this.stroke = stroke;
        this.lineSpacing = lineSpacing;
    }

    get fontString() {
        const family = this.font === 'title' ? QUENTIN_CAPS : this.font === 'emoji' ? EMOJI_FONT : BODY_FONT;
        return `${this.size}px ${family}`;
    }

    get lineHeight() {
        return this.size * 1.18 + this.lineSpacing;
    }

    /** The width of the widest line */
    measure(ctx) {
        ctx.font = this.fontString;
        return Math.max(0, ...this.text.split('\n').map(line => ctx.measureText(line).width));
    }

    drawSelf(ctx) {
        if (!this.text) {
            return;
        }
        const lines = this.text.split('\n');
        ctx.font = this.fontString;
        ctx.textAlign = this.align;
        ctx.textBaseline = 'alphabetic';
        ctx.fillStyle = this.colour;
        //The baseline of the first line
        let y = -(lines.length - 1) * this.lineHeight;
        if (this.baseline === 'middle') {
            //Capital letters are about 0.7 of the font size high
            y = y / 2 + this.size * 0.35;
        }
        for (const line of lines) {
            if (this.stroke) {
                ctx.strokeStyle = this.stroke;
                ctx.lineWidth = Math.max(1, this.size * 0.04);
                ctx.lineJoin = 'round';
                ctx.strokeText(line, 0, y);
            }
            ctx.fillText(line, 0, y);
            y += this.lineHeight;
        }
    }
}

/** The status text in the middle of the table: fades out the previous message and then fades in the new */
export class MessageNode extends LabelNode {
    constructor(size) {
        super({ size, colour: 'black', stroke: 'rgba(255, 255, 255, 0.6)' });
        this.alpha = 0;
    }

    show(message) {
        const stage = this.stage;
        stage.animate(this, { alpha: 0 }, 0.5, {
            then: () => {
                //An empty message just fades out what was there
                if (message) {
                    this.text = message;
                    stage.animate(this, { alpha: 1 }, 0.5);
                }
            },
        });
    }
}

/** A rounded rectangle, centred on its position: the mat under a player's cards */
export class MatNode extends Node {
    constructor(width, height, radius = 20) {
        super();
        this.width = width;
        this.height = height;
        this.radius = radius;
        this.fill = 'gray';
        /** Width of a soft halo round the mat, in its own colour */
        this.glow = 0;
    }

    drawSelf(ctx) {
        if (this.glow > 0) {
            ctx.shadowColor = this.fill;
            ctx.shadowBlur = this.glow * 3;
        }
        ctx.fillStyle = this.fill;
        roundedRect(ctx, -this.width / 2, -this.height / 2, this.width, this.height, this.radius);
        ctx.fill();
    }
}

/** A button with a word on it, in a translucent rounded box. Set onPressed */
export class ButtonNode extends Node {
    constructor(label, fontSize, onPressed) {
        super();
        this.label = new LabelNode({ text: label, size: fontSize, baseline: 'middle' });
        this.onPressed = onPressed;
        this.fill = '255, 255, 255';
        this.isPressed = false;
        //Until it has been drawn and the text measured, a guess
        this.width = label.length * fontSize * 0.75 + 30;
        this.height = fontSize * 0.7 + 30;
    }

    contains(x, y) {
        return Math.abs(x) <= this.width / 2 && Math.abs(y) <= this.height / 2;
    }

    pressChanged(isPressed) {
        this.isPressed = isPressed;
    }

    /** Fade in and out to catch the player's attention */
    attract() {
        this.stage.animate(this, { alpha: 0.5 }, 2.0, { yoyo: true, repeat: Infinity });
    }

    drawSelf(ctx) {
        this.width = this.label.measure(ctx) + 30;
        if (this.isPressed) {
            ctx.shadowColor = 'white';
            ctx.shadowBlur = 20;
        }
        ctx.fillStyle = this.fill.startsWith('rgb') ? this.fill : `rgba(${this.fill}, ${this.isPressed ? 0.75 : 0.25})`;
        roundedRect(ctx, -this.width / 2, -this.height / 2, this.width, this.height, 10);
        ctx.fill();
        ctx.shadowBlur = 0;
        this.label.drawSelf(ctx);
    }
}

/** Looky Looky rules: a round picture button for one of the actions, see show(state) */
export class ActionButtonNode extends Node {
    constructor(image, size, onPressed) {
        super();
        this.image = image;
        this.size = size;
        this.onPressed = () => {
            if (this.state !== 'disabled') {
                onPressed();
            }
        };
        this.state = 'disabled';
        this.alpha = 0.3;
    }

    contains(x, y) {
        return Math.hypot(x, y) <= this.size / 2;
    }

    /** state: 'disabled', 'enabled', or 'selected' which pulses while waiting for the player to pick a card */
    show(state) {
        this.state = state;
        this.stage.stopAnimations(this);
        this.scale = 1.0;
        this.alpha = state === 'disabled' ? 0.3 : 1.0;
        if (state === 'selected') {
            this.stage.animate(this, { scale: 1.2 }, 0.4, { yoyo: true, repeat: Infinity });
        }
    }

    pressChanged(isPressed) {
        if (this.state !== 'disabled') {
            this.alpha = isPressed ? 0.6 : 1.0;
        }
    }

    drawSelf(ctx) {
        ctx.imageSmoothingQuality = 'high';
        ctx.drawImage(this.image, -this.size / 2, -this.size / 2, this.size, this.size);
    }
}

/**
 * A player's lives as yellow hearts, ending at the node's position. Looky Looky rules: a grey heart to the
 * left of them is the extra life the player has yet to win
 */
export class LivesNode extends Node {
    constructor(size, showExtraLife) {
        super();
        this.size = size;
        this.lives = 3;
        this.showExtraLife = showExtraLife;
    }

    drawSelf(ctx) {
        ctx.font = `${this.size}px ${EMOJI_FONT}`;
        ctx.textAlign = 'right';
        ctx.textBaseline = 'alphabetic';
        ctx.fillStyle = 'black';
        const hearts = '💛'.repeat(Math.max(0, this.lives));
        ctx.fillText(hearts, 0, 0);
        if (this.showExtraLife) {
            const alpha = ctx.globalAlpha;
            ctx.globalAlpha = alpha * 0.35;
            ctx.fillText('🖤', -ctx.measureText(hearts).width, 0);
            ctx.globalAlpha = alpha;
        }
    }
}

/**
 * A burst of glowing particles, which removes itself when they have all gone.
 * kind: 'explosion' flies out in all directions (a life lost), 'fire' rises (a player out of the game)
 */
export class ParticleNode extends Node {
    constructor(kind) {
        super();
        this.kind = kind;
        this.particles = [];
        this.age = 0;
        this.emitFor = kind === 'fire' ? 1.6 : 0.25;
        this.rate = kind === 'fire' ? 300 : 800;
        this.toEmit = 0;
    }

    emit() {
        const fire = this.kind === 'fire';
        const angle = fire ? -Math.PI / 2 + (Math.random() - 0.5) * 0.9 : Math.random() * Math.PI * 2;
        const speed = fire ? 60 + Math.random() * 90 : 40 + Math.random() * 160;
        this.particles.push({
            x: fire ? (Math.random() - 0.5) * 120 : 0,
            y: 0,
            vx: Math.cos(angle) * speed,
            vy: Math.sin(angle) * speed,
            life: 0,
            lifetime: fire ? 0.6 + Math.random() * 0.8 : 0.4 + Math.random() * 0.6,
            size: fire ? 10 + Math.random() * 12 : 5 + Math.random() * 8,
        });
    }

    update(dt) {
        this.age += dt;
        if (this.age < this.emitFor) {
            this.toEmit += this.rate * dt;
            while (this.toEmit >= 1) {
                this.toEmit -= 1;
                this.emit();
            }
        }
        for (const p of this.particles) {
            p.life += dt;
            p.x += p.vx * dt;
            p.y += p.vy * dt;
        }
        this.particles = this.particles.filter(p => p.life < p.lifetime);
        if (this.age > this.emitFor && this.particles.length === 0) {
            this.remove();
        }
    }

    drawSelf(ctx) {
        ctx.globalCompositeOperation = 'lighter';
        for (const p of this.particles) {
            const t = p.life / p.lifetime;
            //white hot, to yellow, to red, fading out
            const green = Math.round(230 - 190 * t);
            const blue = Math.round(160 * Math.max(0, 1 - t * 3));
            ctx.fillStyle = `rgba(255, ${green}, ${blue}, ${(1 - t) * 0.5})`;
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.size * (1 - t * 0.6), 0, Math.PI * 2);
            ctx.fill();
        }
    }
}

/**
 * A panel in front of everything else, with a title and a close button (X). It is centred on its position.
 * Subclasses draw their content in drawContent(ctx) and handle presses in pressed(x, y), in the layout's
 * coordinates turned to y down and relative to the centre of the panel: see local().
 * layout: an InformationLayout
 */
export class PanelNode extends Node {
    constructor(layout, title) {
        super();
        this.layout = layout;
        this.title = new LabelNode({ text: title, size: layout.titleFontSize, colour: 'white', baseline: 'alphabetic' });
        this.z = 1000;
        this.x = layout.frame.midX;
        this.y = layout.frame.midY;
        /** Nothing behind the panel can be pressed */
        this.blocksPointer = true;
        this.onDown = (x, y) => {
            const close = this.local(layout.closePosition);
            if (Math.hypot(x - close.x, y - close.y + layout.closeFontSize * 0.35) <= layout.closeFontSize) {
                this.close();
            } else {
                this.pressed(x, y);
            }
        };
        this.onClose = null;
    }

    /** A position of the layout, as a point in the panel's own drawing coordinates */
    local(pos) {
        return { x: pos.x - this.x, y: this.y - pos.y };
    }

    contains(x, y) {
        return Math.abs(x) <= this.layout.frame.width / 2 && Math.abs(y) <= this.layout.frame.height / 2;
    }

    close() {
        this.remove();
        this.onClose?.();
    }

    pressed(x, y) {}

    drawContent(ctx) {}

    drawText(ctx, text, pos, options) {
        const label = new LabelNode({ text, colour: 'white', ...options });
        const at = this.local(pos);
        ctx.save();
        ctx.translate(at.x, at.y);
        label.drawSelf(ctx);
        ctx.restore();
    }

    drawSelf(ctx) {
        const { frame } = this.layout;
        ctx.fillStyle = Colours.rulesBackground;
        roundedRect(ctx, -frame.width / 2, -frame.height / 2, frame.width, frame.height, 10);
        ctx.fill();
        this.drawText(ctx, this.title.text, this.layout.titlePosition, { size: this.layout.titleFontSize });
        this.drawText(ctx, 'X', this.layout.closePosition, { font: 'body', size: this.layout.closeFontSize });
        this.drawContent(ctx);
    }
}

/** A panel that shows a message, for the player's stats at the end of a game */
export class DialogNode extends PanelNode {
    constructor(layout, title, message) {
        super(layout, title);
        this.message = message;
    }

    drawContent(ctx) {
        this.drawText(ctx, this.message.trim(), this.layout.bodyPosition,
            { font: 'body', size: this.layout.bodyFontSize, baseline: 'middle', lineSpacing: this.layout.lineSpacing });
    }
}
