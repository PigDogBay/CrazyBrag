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
                let defaults = UserDefaults.standard
                defaults.set(newVersion, forKey: versionKey)
            }
        }
    }

    func registerDefaultSettings() {
        let defaultSettings : [ String : Any] = [versionKey : getBuildVersion()]
        UserDefaults.standard.register(defaults: defaultSettings)
    }

}
