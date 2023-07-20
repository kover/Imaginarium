//
//  UserResult.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 20.07.2023.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
