//
//  APIService.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/12.
//

import Foundation

enum APIError: Error {
    case invalidUrl
    case encodingError
    case decodingError
    case severError(Int)
    case networkError(Error)
    case unknownError
}

class APIService {

    func send<T: APIResponse>(request: APIRequest,
                              body: APIBody? = nil) async throws -> T {

        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        let encoder = JSONEncoder()

        if let body = body {
            urlRequest.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
