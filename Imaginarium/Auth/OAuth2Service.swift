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
        let request = authTokenRequest(code: code)
        _ = object(for: request) { [weak self] result in
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
    }
}

extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completiion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result {
                    try decoder.decode(OAuthTokenResponseBody.self, from: data)
                }
            }
            completiion(response)
        }
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
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

