//
//  UserService.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/12.
//

import Foundation

class UserService: APIService {
    
    static let shared = UserService()
    private override init() {}
    
    func getUserData(token: String? = nil) async throws -> GetUserDataResponse {
        
        guard let url = URL(string: KoKoAPI.Endpoint.getUserData.urlString) else {
            throw APIError.invalidUrl
        }
        
        let request = APIRequest(url: url, method: .get)
        
        return try await self.send(request: request)
    }
    
}
