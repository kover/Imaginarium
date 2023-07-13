//
//  NetworkServiceProtocol.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 13.07.2023.
//

import Foundation

protocol NetworkService {
    var urlSession: URLSession { get set }
    
    func object<T: Codable>(
        _ type: T.Type,
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask
}

extension NetworkService {
    func object<T: Codable>(
        _ type: T.Type,
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<T, Error> in
                Result {
                    try decoder.decode(T.self, from: data)
                }
            }
            completion(response)
        }
    }
}
