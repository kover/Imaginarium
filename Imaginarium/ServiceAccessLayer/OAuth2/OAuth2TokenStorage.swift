//
//  OAuth2TokenStorage.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.07.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: ApplicationTag)
        }
        
        set {
            guard let token = newValue else {
                return
            }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: ApplicationTag)
            guard isSuccess else {
                assertionFailure("Unable to store token")
                return
            }
        }
    }
}
