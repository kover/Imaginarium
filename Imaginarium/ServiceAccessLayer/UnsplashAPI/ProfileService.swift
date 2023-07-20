//
//  UnsplashService.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.07.2023.
//

import Foundation

final class ProfileService: ProfileServiceProtocol {
    private var urlSession = URLSession.shared
    private var tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    
    private var selfProfileRequest: URLRequest? {
        URLRequest.makeHTTPRequest(path: "/me", token: tokenStorage.token)
    }
    
    private (set) var profile: Profile?
    
    func fetchProfile(completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        guard Thread.isMainThread else {
            return
        }
        task?.cancel()
        
        guard let request = selfProfileRequest else {
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                self.setUserProfile(result: body)
                completion(.success(body))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
    }
    
}

// MARK: - Shared helpers
extension ProfileService {
    private func setUserProfile(result: ProfileResult) {
        let profile = Profile(
            username: result.username,
            name: "\(result.firstName ?? "") \(result.lastName ?? "")",
            loginName: "@\(result.username)",
            bio: result.bio
        )
        self.profile = profile
    }
}
