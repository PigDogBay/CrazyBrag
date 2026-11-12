// The sounds of the web game, played with the Web Audio API.
// A browser will not play any sound until the player has clicked or touched the page, see unlock().

const FILES = {
    'card': 'card.wav',
    'LoseLife': 'LoseLife.wav',
    'Yahoo': 'Yahoo.wav',
    'ricochet': 'ricochet.mp3',
    'sad_whistle': 'sad_whistle.m4a',
    'honky-tonk': 'honky-tonk.m4a',
};

export class Sounds {
    constructor(base = 'assets/sounds/') {
        this.base = base;
        this.buffers = new Map();
        this.context = null;
        this.music = null;
        this.muted = false;
        /** The music to start once the sound has been unlocked and loaded */
        this.wantedMusic = null;
    }

    /** Starts loading the sounds. The game does not wait for them, a sound that has not arrived is not played */
    load() {
        const AudioContext = globalThis.AudioContext ?? globalThis.webkitAudioContext;
        if (!AudioContext) {
            return;
        }
        this.context = new AudioContext();
        this.master = this.context.createGain();
        this.master.connect(this.context.destination);
        for (const [name, file] of Object.entries(FILES)) {
            fetch(this.base + file)
                .then(response => response.arrayBuffer())
                .then(data => this.context.decodeAudioData(data))
                .then(buffer => {
                    this.buffers.set(name, buffer);
                    this.startWantedMusic();
                })
                .catch(error => console.warn(`Sound ${file} not loaded`, error));
        }
    }

    /** Call when the player first clicks or touches the page, the browser then lets the sound play */
    unlock() {
        if (this.context && this.context.state === 'suspended') {
            this.context.resume().then(() => this.startWantedMusic());
        }
    }

    get isUnlocked() {
        return this.context !== null && this.context.state === 'running';
    }

    setMuted(muted) {
        this.muted = muted;
        if (this.master) {
            this.master.gain.value = muted ? 0 : 1;
        }
    }

    /** Plays a sound once. volume: 0 to 1 */
    play(name, volume = 0.5) {
        const buffer = this.buffers.get(name);
        if (!buffer || !this.isUnlocked) {
            return;
        }
        const source = this.context.createBufferSource();
        source.buffer = buffer;
        const gain = this.context.createGain();
        gain.gain.value = volume;
        source.connect(gain).connect(this.master);
        source.start();
    }

    /** Plays a sound round and round, fading in. It starts as soon as the browser allows */
    startMusic(name, volume = 0.05, fadeIn = 5) {
        this.wantedMusic = { name, volume, fadeIn };
        this.startWantedMusic();
    }

    startWantedMusic() {
        const wanted = this.wantedMusic;
        if (!wanted || this.music || !this.isUnlocked || !this.buffers.has(wanted.name)) {
            return;
        }
        const source = this.context.createBufferSource();
        source.buffer = this.buffers.get(wanted.name);
        source.loop = true;
        const gain = this.context.createGain();
        const now = this.context.currentTime;
        gain.gain.setValueAtTime(0, now);
        gain.gain.linearRampToValueAtTime(wanted.volume, now + wanted.fadeIn);
        source.connect(gain).connect(this.master);
        source.start();
        this.music = { source, gain };
    }

    stopMusic(fadeOut = 0.5) {
        this.wantedMusic = null;
        if (this.music) {
            const { source, gain } = this.music;
            const now = this.context.currentTime;
            gain.gain.cancelScheduledValues(now);
            gain.gain.setValueAtTime(gain.gain.value, now);
            gain.gain.linearRampToValueAtTime(0, now + fadeOut);
            source.stop(now + fadeOut);
            this.music = null;
        }
    }
}
