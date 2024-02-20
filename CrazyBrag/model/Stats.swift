//
//  Stats.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 20/02/2024.
//

import Foundation


struct Stats {
    let played : Int
    let won : Int
    
    var winRate : Float {
        if played == 0 {
            return 0.0
        }
        return Float(won) / Float(played)
    }

    var winRateText : String {
        let rate = winRate * 100.0
        return String(format: "%.0f%%", rate)
    }

    var rank : String {
        switch won {
        case 0...1:
            return "Cowpoke"
        case 2...3:
            return "Buckaroo"
        case 4...5:
            return "Wrangler"
        case 6...7:
            return "Bull Rider"
        case 8...9:
            return "Rodeo King"
        case 10...11:
            return "Gun Slinger"
        case 12...14:
            return "Sharpshooter"
        case 15...19:
            return "Deadeye"
        case 20...29:
            return "Root Beer"
        case 30...39:
            return "Cold Beer"
        case 40...49:
            return "Bourbon"
        case 50...59:
            return "Whiskey"
        case 60...69:
            return "Colt 45"
        case 70...79:
            return "Shotgun"
        case 80...89:
            return "Winchester Rifle"
        case 90...99:
            return "Dynamite"
        case 100...149:
            return "Card Sharp"
        case 150...199:
            return "Scalper"
        case 200...249:
            return "Calamity Jane"
        case 250...299:
            return "Buffalo Bill"
        case 300...349:
            return "Sundance Kid"
        case 350...399:
            return "Doc Holliday"
        case 400...449:
            return "Annie Oakley"
        case 450...499:
            return "Sol Star"
        case 500...549:
            return "Wyatt Earp"
        case 550...599:
            return "Billy The Kid"
        case 600...649:
            return "Boothill"
        case 650...699:
            return "OK Corral"
        case 700...749:
            return "Tombstone"
        case 750...799:
            return "Dodge City"
        case 800...849:
            return "Cheyenne"
        case 850...899:
            return "Sioux"
        case 900...949:
            return "Cherokee"
        case 950...999:
            return "Navajo"
        default:
            return "Card King"
        }
    }
    
    func summary() -> String {
        return "Games Played \(played)\nGames Won \(won)\nWin Rate \(winRateText)"
    }
    
}
