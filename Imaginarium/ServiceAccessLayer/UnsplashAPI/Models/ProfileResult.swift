//
//  ProfileResult.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 20.07.2023.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName, lastName: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
