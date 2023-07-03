//
//  OAuth2TokenStorage.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.07.2023.
//

import Foundation

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            return userDefaults.string(forKey: Keys.token.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}
