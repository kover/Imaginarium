//
//  URLRequest+MakeHTTPRequest.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 30.06.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String = "GET",
        baseURL: URL = DefaultBaseURL
    ) -> URLRequest? {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        if let authToken = OAuth2TokenStorage().token {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
