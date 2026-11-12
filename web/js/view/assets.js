// The images and the font of the web game, built into web/assets by tools/web/build.sh
import { PlayingCard, Rank } from '../model/playingCard.js';

export const QUENTIN_CAPS = 'QuentinCaps';
/** The iOS game uses American Typewriter for the rules, which only Apple devices have */
export const BODY_FONT = '"American Typewriter", AmericanTypewriter, Rockwell, "Courier New", serif';
export const EMOJI_FONT = '"Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji", sans-serif';

const PLAIN_BACK = 'CardBack';
const ACTION_IMAGES = ['ActionLooky', 'ActionStash', 'ActionChange'];

/** The name of the card's face image: KH, 10D, JokerGood */
export function cardImageName(card) {
    if (card.rank === Rank.goodJoker) {
        return 'JokerGood';
    }
    if (card.rank === Rank.badJoker) {
        return 'JokerBad';
    }
    return Rank.display(card.rank) + ['C', 'D', 'H', 'S'][card.suit];
}

/**
 * The name of the image for the back of the card. With the marked deck ("Howie's deck") each card has its own
 * back, marked so that a sharp eyed player can read it. Otherwise all the cards share the plain back.
 */
export function cardBackImageName(card, markedDeck) {
    return markedDeck ? 'Back' + cardImageName(card) : PLAIN_BACK;
}

export class Assets {
    constructor(base = 'assets/') {
        this.base = base;
        this.images = new Map();
    }

    /** The image, which must have been loaded */
    image(name) {
        const image = this.images.get(name);
        if (!image) {
            throw new Error(`No image ${name}`);
        }
        return image;
    }

    loadImage(name, path) {
        return new Promise((resolve, reject) => {
            const image = new Image();
            image.onload = () => {
                this.images.set(name, image);
                resolve();
            };
            image.onerror = () => reject(new Error(`Could not load ${path}`));
            image.src = this.base + path;
        });
    }

    /** Loads every image and the font. onProgress is called with the fraction done, 0 to 1 */
    async load(onProgress = () => {}) {
        const pack = [...PlayingCard.standardPack, PlayingCard.goodJoker, PlayingCard.badJoker];
        const cards = pack.flatMap(card => [cardImageName(card), cardBackImageName(card, true)]);
        const jobs = [
            ...[...cards, PLAIN_BACK].map(name => () => this.loadImage(name, `cards/${name}.webp`)),
            ...ACTION_IMAGES.map(name => () => this.loadImage(name, `${name}.webp`)),
            () => this.loadImage('westerntown', 'westerntown.jpg'),
            async () => {
                const font = new FontFace(QUENTIN_CAPS, `url(${this.base}QuentinCaps.ttf)`);
                document.fonts.add(await font.load());
            },
        ];
        let done = 0;
        await Promise.all(jobs.map(job => job().then(() => {
            done += 1;
            onProgress(done / jobs.length);
        })));
    }
}
