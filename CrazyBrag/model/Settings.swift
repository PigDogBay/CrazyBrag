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
            if newVal != gamesPlayed {
                UserDefaults.standard.set(newVal, forKey: gamesWonKey)
            }
        }
    }
    
    func registerDefaultSettings() {
        let defaultSettings : [ String : Any] = [versionKey : getBuildVersion(),
                                             gamesPlayedKey : 0,
                                                gamesWonKey : 0]
        UserDefaults.standard.register(defaults: defaultSettings)
    }

}
