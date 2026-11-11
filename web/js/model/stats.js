// Ported from CrazyBrag/model/Stats.swift

/** The most games won for each rank, in order */
const ranks = [
    [1, 'Cowpoke'], [3, 'Buckaroo'], [5, 'Wrangler'], [7, 'Bull Rider'], [9, 'Rodeo King'], [11, 'Gun Slinger'],
    [14, 'Sharpshooter'], [19, 'Deadeye'], [29, 'Root Beer'], [39, 'Cold Beer'], [49, 'Bourbon'], [59, 'Whiskey'],
    [69, 'Colt 45'], [79, 'Shotgun'], [89, 'Winchester Rifle'], [99, 'Dynamite'], [149, 'Card Sharp'], [199, 'Scalper'],
    [249, 'Calamity Jane'], [299, 'Buffalo Bill'], [349, 'Sundance Kid'], [399, 'Doc Holliday'], [449, 'Annie Oakley'],
    [499, 'Sol Star'], [549, 'Wyatt Earp'], [599, 'Billy The Kid'], [649, 'Boothill'], [699, 'OK Corral'],
    [749, 'Tombstone'], [799, 'Dodge City'], [849, 'Cheyenne'], [899, 'Sioux'], [949, 'Cherokee'], [999, 'Navajo'],
];

/** The player's record: win rate and the rank title earned by the number of games won */
export class Stats {
    constructor(played, won) {
        this.played = played;
        this.won = won;
    }

    get winRate() {
        return this.played === 0 ? 0.0 : this.won / this.played;
    }

    get winRateText() {
        return `${(this.winRate * 100.0).toFixed(0)}%`;
    }

    get rank() {
        const rank = ranks.find(([most]) => this.won <= most);
        return rank ? rank[1] : 'Card King';
    }

    summary() {
        return `\nGames Won:  ${this.won}\nGames Played:  ${this.played}\nWin Rate:  ${this.winRateText}\n\nRank:\n${this.rank}`;
    }
}
