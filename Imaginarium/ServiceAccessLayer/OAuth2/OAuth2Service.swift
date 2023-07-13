//
//  OAuth2Service.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 30.06.2023.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    
    func fetchAuthToken(
        withCode code: String,
        handler: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastCode == code {
            return
        }

        task?.cancel()
        lastCode = code
        
        guard let request = authTokenRequest(code: code) else {
            fatalError("Unable to create fetch authorization token request")
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                handler(.success(authToken))
            case .failure(let error):
                handler(.failure(error))
            }
        }
        self.task = task
    }
}

// MARK: - Shared helpers
extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com"),
                let request = URLRequest.makeHTTPRequest(
                    path: "/oauth/token"
                    + "?client_id=\(AccessKey)"
                    + "&&client_secret=\(SecretKey)"
                    + "&&redirect_uri=\(RedirectURI)"
                    + "&&code=\(code)"
                    + "&&grant_type=authorization_code",
                    httpMethod: "POST",
                    baseURL: url)
        else {
            return nil
        }
        return request
    }
    
    private struct OAuthTokenResponseBody: Decodable {
        var accessToken: String
        var tokenType: String
        var scope: String
        var createdAt: Int
        
        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
}

