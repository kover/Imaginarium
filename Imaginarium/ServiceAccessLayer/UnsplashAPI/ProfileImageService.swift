//
//  ProfileImageService.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 13.07.2023.
//

import Foundation

final class ProfileImageService: ProfileImageServiceProtocol {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private var tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    
    private (set) var avatarURL: String?
    
    private func profileImageURLRequest(username: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/users/\(username)", token: tokenStorage.token)
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard Thread.isMainThread else {
            return
        }
        task?.cancel()
        
        guard let request = profileImageURLRequest(username: username) else {
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let profileImageURL = body.profileImage.medium
                self.avatarURL = profileImageURL
                completion(.success(body.profileImage.medium))
                NotificationCenter.default
                    .post(name: ProfileImageService.didChangeNotification,
                          object: self,
                          userInfo: ["URL": profileImageURL]
                    )
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
    }
    
}
