// Shared named hands for the tests, ported from CrazyBragTests/Hands.swift
import { PlayingCard } from '../js/model/playingCard.js';

/** cards('kd', 'gj', 'kh') -> the three PlayingCards */
export function cards(...flattened) {
    return flattened.map(text => {
        const card = PlayingCard.unflatten(text);
        if (!card) {
            throw new Error(`Bad card ${text}`);
        }
        return card;
    });
}

export const PrialOfAces = cards('ac', 'ah', 'as');
export const PrialOfKings = cards('kd', 'kh', 'ks');
export const PrialOfThrees = cards('3c', '3d', '3s');
export const PrialOfFours = cards('4c', '4d', '4s');
export const StateExpress = cards('5c', '5d', '5s');
export const JQKTrotter = cards('qs', 'js', 'ks');
export const A23Trotter = cards('2d', 'ad', '3d');
export const JQKRun = cards('qc', 'jd', 'kd');
export const A23Run = cards('2c', '3d', 'ad');
export const AKQRun = cards('kc', 'ad', 'qd');
export const Weetabix456Run = cards('5c', '6s', '4h');
export const Beehive345Run = cards('5c', '3s', '4h');
export const Beehive345Run2 = cards('5s', '3h', '4c');
export const AKJFlush = cards('ad', 'jd', 'kd');
export const KJTFlush = cards('td', 'jd', 'kd');
export const KQTFlush = cards('th', 'qh', 'kh');
export const KJ9Flush = cards('9s', 'js', 'ks');
export const QQKPair = cards('qc', 'qs', 'kd');
export const QQAPair = cards('qc', 'qd', 'ad');
export const AAQPair = cards('ac', 'qd', 'ad');
export const KQ2High = cards('qc', '2d', 'kd');
export const KQ3High = cards('qc', '3h', 'kd');
export const A42High = cards('2c', 'ad', '4d');
