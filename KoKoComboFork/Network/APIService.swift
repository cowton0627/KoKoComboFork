//
//  APIService.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/12.
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
                              body: APIBody? = nil,
                              token: String? = nil) async throws -> T {
        
        var urlRequest = URLRequest(url: URL(string: "\(request.url)")!)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = token {
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorzation")
        }
        
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
    
    
//    func send<T: APIResponse>(request: APIRequest, 
//                              token: String? = nil) async throws -> T {
//        
//        var urlRequest = URLRequest(url: URL(string: "\(request.url)")!)
//        urlRequest.httpMethod = request.method.rawValue
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
//        
//        if let token = token {
//            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorzation")
//        }
//        
//        let (data, response) = try await URLSession.shared.data(for: urlRequest)
//        
//        if let httpResponse = response as? HTTPURLResponse {
//            print(httpResponse.statusCode)
//        }
//        
//        let decoder = JSONDecoder()
//        return try decoder.decode(T.self, from: data)
//    }
}
