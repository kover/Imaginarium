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
        baseURL: URL = DefaultBaseURL,
        token: String? = nil
    ) -> URLRequest? {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        // Append token if present
        if let oauthToken = token {
            request.setValue("Bearer \(oauthToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
