// Ported from CrazyBrag/model/Settings.swift

/** Somewhere to keep the settings when the browser will not let the page use its local storage */
class MemoryStorage {
    constructor() {
        this.items = new Map();
    }
    getItem(key) {
        return this.items.has(key) ? this.items.get(key) : null;
    }
    setItem(key, value) {
        this.items.set(key, String(value));
    }
}

function browserStorage() {
    try {
        const storage = globalThis.localStorage;
        //Reading can be refused as well, for a game embedded in another site's page
        storage.getItem('crazybrag.version');
        return storage;
    } catch {
        return null;
    }
}

/**
 * The player's settings and record, kept in the browser's local storage:
 * games played and won, the game mode and the deck to use.
 */
export class Settings {
    /** storage: anything with getItem(key) and setItem(key, value), by default the browser's local storage */
    constructor(storage = browserStorage() ?? new MemoryStorage()) {
        this.storage = storage;
    }

    read(key, defaultValue) {
        try {
            const value = this.storage.getItem(`crazybrag.${key}`);
            return value === null || value === undefined ? defaultValue : JSON.parse(value);
        } catch {
            return defaultValue;
        }
    }

    write(key, value) {
        try {
            this.storage.setItem(`crazybrag.${key}`, JSON.stringify(value));
        } catch {
            //The setting lasts for this visit only
        }
    }

    get gamesPlayed() { return this.read('gamesPlayed', 0); }
    set gamesPlayed(value) { this.write('gamesPlayed', value); }

    get gamesWon() { return this.read('gamesWon', 0); }
    set gamesWon(value) { this.write('gamesWon', value); }

    /**
     * Howie's deck: when true the backs of the cards are marked so that an observant player can read them,
     * when false every card has the same plain back
     */
    get markedDeck() { return this.read('markedDeck', true); }
    set markedDeck(value) { this.write('markedDeck', value); }

    /** Game mode: when true the game is played with the extra Looky Looky rules, when false with the standard rules */
    get lookyLooky() { return this.read('lookyLooky', true); }
    set lookyLooky(value) { this.write('lookyLooky', value); }
}

export { MemoryStorage };
