//
//  Settings.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 09/02/2024.
//

import Foundation

class Settings
{
    private let versionKey = "version"
    private let gamesPlayedKey = "gamesPlayed"
    private let gamesWonKey = "gamesWon"
    private let markedDeckKey = "markedDeck"

    func setInformationVersion(){
        version = getBuildVersion()
    }
    
    private func getBuildVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion ?? ""
    }
    
    private var version : String {
        get { return UserDefaults.standard.string(forKey: versionKey) ?? ""}
        set(newVersion) {
            if newVersion != version {
                UserDefaults.standard.set(newVersion, forKey: versionKey)
            }
        }
    }
    
    var gamesPlayed : Int {
        get {return UserDefaults.standard.integer(forKey: gamesPlayedKey)}
        set(newVal) {
            if newVal != gamesPlayed {
                UserDefaults.standard.set(newVal, forKey: gamesPlayedKey)
            }
        }
    }
    
    var gamesWon : Int {
        get {return UserDefaults.standard.integer(forKey: gamesWonKey)}
        set(newVal) {
            if newVal != gamesWon {
                UserDefaults.standard.set(newVal, forKey: gamesWonKey)
            }
        }
    }
    
    ///Howie's deck: when true the backs of the cards are marked so that an observant player can read them,
    ///when false every card has the same plain back
    var markedDeck : Bool {
        get {return UserDefaults.standard.bool(forKey: markedDeckKey)}
        set(newVal) {
            if newVal != markedDeck {
                UserDefaults.standard.set(newVal, forKey: markedDeckKey)
            }
        }
    }

    func registerDefaultSettings() {
        let defaultSettings : [ String : Any] = [versionKey : getBuildVersion(),
                                             gamesPlayedKey : 0,
                                                gamesWonKey : 0,
                                              markedDeckKey : true]
        UserDefaults.standard.register(defaults: defaultSettings)
    }

}
