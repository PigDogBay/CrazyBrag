// A game view for the tests: it draws nothing, it records what the presenter asks of it

export class FakeView {
    constructor() {
        /** Everything the view was asked to do, as [method name, ...arguments] */
        this.calls = [];
        this.messages = [];
        this.sounds = [];
        this.faceUp = new Map();
        this.positions = new Map();
        this.zPositions = new Map();
        this.buttons = {};
        this.isContinueShowing = false;
        this.dialog = null;
        this.hasQuit = false;
    }

    record(name, ...args) {
        this.calls.push([name, ...args]);
    }

    /** The calls made to one method, without the method name */
    callsTo(name) {
        return this.calls.filter(call => call[0] === name).map(call => call.slice(1));
    }

    get lastMessage() {
        return this.messages[this.messages.length - 1];
    }

    quit() { this.record('quit'); this.hasQuit = true; }
    setZPosition(card, z) { this.record('setZPosition', card, z); this.zPositions.set(card, z); }
    setPosition(card, pos, duration, delay) { this.record('setPosition', card, pos, duration, delay); this.positions.set(card, pos); }
    addName(name, pos) { this.record('addName', name, pos); }
    turn(card, isFaceUp) { this.record('turn', card, isFaceUp); this.faceUp.set(card, isFaceUp); }
    addLives(name, pos) { this.record('addLives', name, pos); }
    addTableMat(seat) { this.record('addTableMat', seat); }
    updateScore(player) { this.record('updateScore', player); }
    extraLife(player) { this.record('extraLife', player); }
    updateDealer(player) { this.record('updateDealer', player); }
    removePlayer(player) { this.record('removePlayer', player); }
    highlight(player, status) { this.record('highlight', player, status); }
    show(message) { this.record('show', message); this.messages.push(message); }
    play(soundName) { this.record('play', soundName); this.sounds.push(soundName); }
    continueButton(show) { this.record('continueButton', show); this.isContinueShowing = show; }
    discard(card, pos, duration) { this.record('discard', card, pos, duration); this.positions.set(card, pos); }
    setActionButton(action, state) { this.record('setActionButton', action, state); this.buttons[action] = state; }
    showMessage(title, message) { this.record('showMessage', title, message); this.dialog = { title, message }; }
}

/** A start screen view: the animations do not run, their completions are queued to be run one at a time by step() */
export class FakeStartView {
    constructor() {
        this.calls = [];
        this.completions = [];
    }

    record(name, completion, ...args) {
        this.calls.push([name, ...args]);
        if (completion) {
            this.completions.push(completion);
        }
    }

    /** Finishes the oldest animation still running. Returns false if there is none */
    step() {
        const completion = this.completions.shift();
        completion?.();
        return completion !== undefined;
    }

    names() {
        return this.calls.map(call => call[0]);
    }

    setZ(card, z) { this.record('setZ', null, card, z); }
    actionMove(card, pos, duration, completion) { this.record('actionMove', completion, card, pos, duration); }
    actionGather(card, pos, duration, completion) { this.record('actionGather', completion, card, pos, duration); }
    actionTurnCard(card, duration, completion) { this.record('actionTurnCard', completion, card, duration); }
    actionSpread(hand, byX, completion) { this.record('actionSpread', completion, hand, byX); }
    actionWait(duration, completion) { this.record('actionWait', completion, duration); }
    actionFadeInName(name, duration) { this.record('actionFadeInName', null, name, duration); }
    actionFadeOutName(duration) { this.record('actionFadeOutName', null, duration); }
}
