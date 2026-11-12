// Ported from InformationNode.swift and SettingsNode.swift: the rules and the game settings panels of the start screen
import { PanelNode, roundedRect } from './nodes.js';
import { point } from '../presenter/layout.js';
import { deadwoodPages, lookyLookyPages } from './rules.js';

/** Draws one of the choice buttons of a panel: a rounded box with a word in it. Selected is white with dark letters */
function drawOption(panel, ctx, text, pos, size, fontSize, selected) {
    const at = panel.local(pos);
    ctx.fillStyle = `rgba(255, 255, 255, ${selected ? 0.9 : 0.12})`;
    ctx.strokeStyle = 'white';
    ctx.lineWidth = 2;
    roundedRect(ctx, at.x - size.width / 2, at.y - size.height / 2, size.width, size.height, size.height / 4);
    ctx.fill();
    ctx.stroke();
    panel.drawText(ctx, text, pos, { size: fontSize, baseline: 'middle', colour: selected ? 'black' : 'white' });
}

function isInside(panel, x, y, pos, size) {
    const at = panel.local(pos);
    return Math.abs(x - at.x) <= size.width / 2 && Math.abs(y - at.y) <= size.height / 2;
}

/**
 * The rules. The first page offers the two sets of rules, Deadwood (the standard game) and Looky Looky,
 * choosing one shows its pages, which are stepped through with < and >. Going back from the first page
 * returns to the choice.
 */
export class InformationNode extends PanelNode {
    constructor(layout) {
        super(layout, 'RULES');
        /** The rules being read, null while the player is choosing between them */
        this.pages = null;
        this.index = 1;
        this.body = '';
        this.bodyAlpha = 0;
    }

    /** Fades out the text and then fades in the new */
    show(message) {
        this.stage.animate(this, { bodyAlpha: 0 }, 0.5, {
            then: () => {
                this.body = message;
                if (message) {
                    this.stage.animate(this, { bodyAlpha: 1 }, 0.5);
                }
            },
        });
    }

    /** Back to choosing the rules */
    showOptions() {
        this.pages = null;
        this.index = 1;
        this.title.text = 'RULES';
        this.show('');
    }

    /** The options go and the pages of the chosen rules can be stepped through */
    select(pages, title) {
        this.pages = pages;
        this.index = 1;
        this.title.text = title;
        this.updatePage();
    }

    selectDeadwood() {
        this.select(deadwoodPages, 'DEADWOOD');
    }

    selectLookyLooky() {
        this.select(lookyLookyPages, 'LOOKY LOOKY');
    }

    updatePage() {
        if (this.pages) {
            this.show(this.pages[this.index - 1]);
        }
    }

    /** Going back from the first page returns to the choice of rules */
    previous() {
        if (!this.pages) {
            return;
        }
        if (this.index === 1) {
            this.showOptions();
            return;
        }
        this.index -= 1;
        this.updatePage();
    }

    next() {
        if (this.pages && this.index < this.pages.length) {
            this.index += 1;
            this.updatePage();
        }
    }

    pressed(x, y) {
        const layout = this.layout;
        if (!this.pages) {
            if (isInside(this, x, y, layout.option1Position, layout.optionSize)) {
                this.selectDeadwood();
            } else if (isInside(this, x, y, layout.option2Position, layout.optionSize)) {
                this.selectLookyLooky();
            }
            return;
        }
        //Generous areas round the < and >, they are small to hit with a finger
        const control = { width: layout.controlFontSize * 1.6, height: layout.controlFontSize * 1.6 };
        const raise = pos => point(pos.x, pos.y + layout.controlFontSize * 0.3);
        if (isInside(this, x, y, raise(layout.previousPosition), control)) {
            this.previous();
        } else if (isInside(this, x, y, raise(layout.nextPosition), control)) {
            this.next();
        }
    }

    drawContent(ctx) {
        const layout = this.layout;
        if (!this.pages) {
            drawOption(this, ctx, 'DEADWOOD', layout.option1Position, layout.optionSize, layout.optionFontSize, false);
            drawOption(this, ctx, 'LOOKY LOOKY', layout.option2Position, layout.optionSize, layout.optionFontSize, false);
        } else {
            this.drawText(ctx, '<', layout.previousPosition, { font: 'body', size: layout.controlFontSize });
            this.drawText(ctx, '>', layout.nextPosition, { font: 'body', size: layout.controlFontSize });
            this.drawText(ctx, `${this.index} of ${this.pages.length}`, layout.pagePosition, { font: 'body', size: layout.pageFontSize });
        }
        if (this.body && this.bodyAlpha > 0) {
            const alpha = ctx.globalAlpha;
            ctx.globalAlpha = alpha * this.bodyAlpha;
            this.drawText(ctx, this.body, layout.bodyPosition,
                { font: 'body', size: layout.bodyFontSize, baseline: 'middle', lineSpacing: layout.lineSpacing });
            ctx.globalAlpha = alpha;
        }
    }
}

/**
 * The game settings: choose the game mode and the deck. The choices are saved straightaway.
 * settings: the player's Settings
 * onDeckChanged: called when the deck is changed, so that cards already on screen can change their backs
 */
export class SettingsNode extends PanelNode {
    constructor(layout, settings, onDeckChanged) {
        super(layout, 'GAME SETTINGS');
        this.settings = settings;
        this.onDeckChanged = onDeckChanged;
        //Rows are placed in proportion to the panel, which is 400 high on the phone layout
        const frame = layout.frame;
        const unit = this.unit = frame.height / 400.0;
        this.optionSize = { width: 210.0 * unit, height: 54.0 * unit };
        const row = (title, y, left, right) => ({
            title,
            titlePosition: point(frame.midX, y),
            options: [
                { ...left, position: point(frame.midX - 115.0 * unit, y - 48.0 * unit) },
                { ...right, position: point(frame.midX + 115.0 * unit, y - 48.0 * unit) },
            ],
        });
        this.rows = [
            row('GAME', frame.y + 262.0 * unit, { text: 'DEADWOOD', setting: 'lookyLooky', value: false }, { text: 'LOOKY LOOKY', setting: 'lookyLooky', value: true }),
            row('DECK', frame.y + 137.0 * unit, { text: 'PLAIN', setting: 'markedDeck', value: false }, { text: 'MARKED', setting: 'markedDeck', value: true }),
        ];
    }

    /** setting: 'lookyLooky' or 'markedDeck' */
    select(setting, value) {
        if (this.settings[setting] === value) {
            return;
        }
        this.settings[setting] = value;
        if (setting === 'markedDeck') {
            this.onDeckChanged?.();
        }
    }

    pressed(x, y) {
        for (const option of this.rows.flatMap(row => row.options)) {
            if (isInside(this, x, y, option.position, this.optionSize)) {
                this.select(option.setting, option.value);
            }
        }
    }

    drawContent(ctx) {
        for (const row of this.rows) {
            this.drawText(ctx, row.title, row.titlePosition, { font: 'body', size: this.layout.bodyFontSize });
            for (const option of row.options) {
                drawOption(this, ctx, option.text, option.position, this.optionSize, 24.0 * this.unit,
                    this.settings[option.setting] === option.value);
            }
        }
    }
}
