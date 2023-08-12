//
//  Constants.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 28.06.2023.
//

import Foundation

let AccessKey = "5-k8-rZahLYNtEvmZbjzM3Z3a3GfJ2WHyuWEfZUt880"
let SecretKey = "vyxyuF2yjJZV8v_sqiXDD_HbEa3sxPblvEx8dtW2LdA"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"

let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL = URL(string: "https://api.unsplash.com/")!

let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
let ApplicationTag = "com.imaginarium"

struct AuthConfiguration {
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: AccessKey,
            secretKey: SecretKey,
            redirectURI: RedirectURI,
            accessScope: AccessScope,
            defaultBaseURL: DefaultBaseURL,
            authURLString: UnsplashAuthorizeURLString
        )
    }
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}

