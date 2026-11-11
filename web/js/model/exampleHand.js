// Ported from CrazyBrag/model/ExampleHand.swift
import { PlayingCard } from './playingCard.js';

const flattened = [
    '2s,3h,5d,5 Stinking High',
    '7h,tc,jd,Jack High',
    '2d,qh,ks,King High',
    '2s,4h,Ah,Ace High',
    'jc,kd,As,Ace High',
    '2c,2d,jh,Dogs',
    '3c,3h,2h,Pair of Threes',
    'ts,th,4c,Blankets',
    'kh,Ks,jd,Pair of Kings',
    'Ah,Ad,ks,Bullets',
    '2d,3d,5d,5 Flush',
    '3h,5h,9h,9 Flush',
    '6c,7c,jc,Jack Flush',
    '4s,8s,ks,King Flush',
    'jd,kd,ad,Ace Flush',
    '2d,3d,4s,2-3-4',
    '3s,4s,5d,3-4-5 Beehive',
    '4c,5d,6h,4-5-6 Tom Mix',
    '7h,8d,9h,7-8-9 Woodbine',
    '9h,tc,jd,9-10-Jack Burt Bacharach',
    'th,js,qc,Ten-Joe-Green',
    'jh,qd,kc,Jack-Queen-King',
    'qd,kc,ah,Acker-Boo',
    'as,2d,3c,Up a Tree',
    '2s,3s,4s,2-3-4 Trotter',
    '7c,8c,9c,7-8-9 Trotter',
    'th,jh,qh,10-Jack-Queen Trotter',
    'qd,kd,ad,Acker Trotter',
    'as,2s,3s,1-2-3 Trotter',
    '2c,2h,2s,Prial of Dogs',
    'tc,th,td,Prial of Blankets',
    'kh,ks,kd,Prial of Kings',
    'as,ad,ah,Prial of Bullets',
    '3c,3d,3s,Yippee Ki-Yay',
];

/** A named hand, shown on the start screen */
export class ExampleHand {
    constructor(hand, name) {
        this.hand = hand;
        this.name = name;
    }

    /** "2h,2c,jd,Dogs": three cards and the name. Returns null if it is not that */
    static unflatten(text) {
        const parts = text.split(',');
        if (parts.length !== 4) {
            return null;
        }
        const hand = parts.slice(0, 3).map(part => PlayingCard.unflatten(part));
        if (hand.includes(null)) {
            return null;
        }
        return new ExampleHand(hand, parts[3]);
    }

    static examples() {
        return flattened.map(text => ExampleHand.unflatten(text)).filter(example => example !== null);
    }
}
