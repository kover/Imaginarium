//
//  ProfileServiceProtocol.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 20.07.2023.
//

import Foundation

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(completion: @escaping (Result<ProfileResult, Error>) -> Void)
}
