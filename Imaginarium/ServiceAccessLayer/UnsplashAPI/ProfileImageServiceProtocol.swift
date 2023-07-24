//
//  ProfileImageServiceProtocol.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 20.07.2023.
//

import Foundation

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}
