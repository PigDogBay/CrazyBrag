// Ported from IPadLayout.swift, IPhoneLayout.swift and StartLayout.swift
//
// Positions are in a fixed logical coordinate space for each layout, as in the iOS game:
// the origin is the BOTTOM left and y goes UP. The view turns them into canvas coordinates and scales to the screen.

/** Drawing order, higher is in front */
export const Layer = Object.freeze({
    background: 0, tableMat: 1, ui: 2, messages: 3, card1: 4, card2: 5, card3: 6, deck: 7, continueButton: 8, particles: 9,
});

export function point(x, y) {
    return Object.freeze({ x, y });
}

export class Rect {
    constructor(x, y, width, height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        Object.freeze(this);
    }
    get midX() { return this.x + this.width / 2; }
    get midY() { return this.y + this.height / 2; }
    get maxX() { return this.x + this.width; }
    get maxY() { return this.y + this.height; }
}

/** Where the three cards, the name, the lives and the dealer token go for a seat's frame */
class CardPosition {
    constructor(frame, cardSize, yNameOffset) {
        this.frame = frame;
        this.positions = [
            point(cardSize.width / 2.0 + frame.x, frame.midY),
            point(frame.midX, frame.midY),
            point(frame.maxX - cardSize.width / 2.0, frame.midY),
        ];
        this.namePos = point(frame.x, frame.maxY + yNameOffset);
        this.livesPos = point(frame.maxX, frame.maxY + yNameOffset);
        this.dealerTokenPos = point(frame.x - 10.0, frame.midY);
    }
}

/** A card's place in the drawing order: the three cards of a hand overlap, the last dealt in front */
export function zPosition(dealt) {
    switch (dealt.cardCount) {
        case 1: return Layer.card1;
        case 2: return Layer.card2;
        default: return Layer.card3;
    }
}

/** Seats: -1 is the middle, 0 is the human, 1... are the computer players clockwise */
class TableLayout {
    /** frames: the rectangle that holds the three cards for the middle (first) and then each seat */
    constructor(frames) {
        this.yNameOffset = 8.0;
        this.frames = frames;
    }

    get numberOfAIPlayers() {
        return this.frames.length - 2;
    }

    getCardPosition(seat) {
        const frame = this.frames[seat + 1];
        if (!frame) {
            throw new Error(`Bad seat position ${seat}`);
        }
        return new CardPosition(frame, this.cardSize, this.yNameOffset);
    }

    getNamePosition(seat) {
        return this.getCardPosition(seat).namePos;
    }

    getLivesPosition(seat) {
        return this.getCardPosition(seat).livesPos;
    }

    getDealerPosition(seat) {
        return this.getCardPosition(seat).dealerTokenPos;
    }

    /** Where a DealtCard goes */
    getPosition(dealt) {
        const position = this.getCardPosition(dealt.seat).positions[dealt.cardCount - 1];
        if (!position) {
            throw new Error(`Bad index ${dealt.cardCount}`);
        }
        return position;
    }

    getFrame(seat) {
        return this.getCardPosition(seat).frame;
    }
}

/** The 4:3 table, with five computer players */
export class IPadLayout extends TableLayout {
    constructor() {
        const w = 100.0, h = 153.0;
        super([
            new Rect(352.0, 307.5, 3.0 * (w + 7.0), h),     //middle
            new Rect(352.0, 38.0, 3.0 * (w + 7.0), h),      //player
            new Rect(51.0, 308.0, 2.0 * w, h),              //west
            new Rect(60.0, 570.0, 2.0 * w, h),              //north west
            new Rect(412.0, 570.0, 2.0 * w, h),             //north
            new Rect(764.0, 570.0, 2.0 * w, h),             //north east
            new Rect(772.0, 308.0, 2.0 * w, h),             //east
        ]);
        this.isPhone = false;
        this.size = Object.freeze({ width: 1024.0, height: 768.0 });
        this.cardSize = Object.freeze({ width: w, height: h });
        this.fonts = Object.freeze({ nameFontSize: 24.0, livesFontSize: 18.0, buttonFontSize: 36.0, dealerFontSize: 36.0, statusFontSize: 28.0 });
        this.deckPosition = point(100, 100);
        this.message = point(872.0, 120.0);
        this.backButton = point(950.0, 45.0);
        this.continueButton = point(512.0, 116.0);
        /** Looky Looky rules: the action buttons, next to the player's hand */
        this.actionButtonSize = 50.0;
        this.actionButtons = [point(716.0, 170.0), point(716.0, 114.5), point(716.0, 59.0)];
    }
}

/** The wide table, with four computer players */
export class IPhoneLayout extends TableLayout {
    constructor() {
        const w = 85.0, h = 130.0;
        super([
            new Rect(330.0, 280.0, 3.0 * (w + 6.0), h),     //middle
            new Rect(330.0, 32.0, 3.0 * (w + 6.0), h),      //player
            new Rect(56.0, 80.0, 2.0 * w, h),               //west
            new Rect(70.0, 264.0, 2.0 * w, h),              //north west
            new Rect(701.0, 264.0, 2.0 * w, h),             //north east
            new Rect(715.0, 80.0, 2.0 * w, h),              //east
        ]);
        this.isPhone = true;
        this.size = Object.freeze({ width: 932.0, height: 430.0 });
        this.cardSize = Object.freeze({ width: w, height: h });
        this.fonts = Object.freeze({ nameFontSize: 16.0, livesFontSize: 12.0, buttonFontSize: 20.0, dealerFontSize: 26.0, statusFontSize: 22.0 });
        this.deckPosition = point(100, -70.0);
        this.message = point(466.0, 207.0);
        this.backButton = point(870.0, 30.0);
        this.continueButton = point(467.0, 97.0);
        this.actionButtonSize = 40.0;
        this.actionButtons = [point(641.0, 142.0), point(641.0, 97.0), point(641.0, 52.0)];
    }

    getDealerPosition(seat) {
        if (seat === 1 || seat === 2) {
            //Place dealer token on the inside
            const frame = this.getFrame(seat);
            return point(frame.maxX + 40.0, frame.midY);
        }
        return super.getDealerPosition(seat);
    }
}

/** The start screen */
export class StartLayout {
    constructor(isPhone) {
        this.isPhone = isPhone;
        this.spreadOffset = 50.0;
        this.stepOffset = 25;
        if (isPhone) {
            this.size = Object.freeze({ width: 932.0, height: 430.0 });
            this.cardSize = Object.freeze({ width: 85.0, height: 130.0 });
            this.titleFontSize = 64.0;
            this.buttonFontSize = 36.0;
            this.nameFontSize = 28.0;
            this.cardX = 441;
            this.cardY = 210;
            this.deckPos = point(150.0, 120.0);
            this.titlePos = point(466.0, 340.0);
            this.namePos = point(466.0, 70.0);
            this.dealButtonPos = point(800.0, 70.0);
            this.rulesButtonPos = point(800.0, 190.0);
            this.settingsButtonPos = point(800.0, 310.0);
        } else {
            this.size = Object.freeze({ width: 1024.0, height: 768.0 });
            this.cardSize = Object.freeze({ width: 119.0, height: 182.0 });
            this.titleFontSize = 96.0;
            this.buttonFontSize = 48.0;
            this.nameFontSize = 44.0;
            this.cardX = 487;
            this.cardY = 400;
            this.deckPos = point(100.0, 100.0);
            this.titlePos = point(512.0, 576.0);
            this.namePos = point(512.0, 220.0);
            this.dealButtonPos = point(512.0, 120.0);
            this.rulesButtonPos = point(910.0, 120.0);
            this.settingsButtonPos = point(910.0, 230.0);
        }
    }

    cardPosition(index) {
        return point(this.cardX + index * this.stepOffset, this.cardY);
    }
}
