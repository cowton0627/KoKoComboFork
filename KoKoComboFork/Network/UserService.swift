//
//  UserService.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/12.
//

import Foundation

protocol UserServicing {
    func getUserData() async throws -> GetUserDataResponse
    func getFriendsData(scenario: Int) async throws -> GetFriendsResponse
}

/// 使用者服務
class UserService: APIService, UserServicing {

    static let shared = UserService()
    private override init() {}

    /// 取回使用者資料
    func getUserData() async throws -> GetUserDataResponse {

        guard let url = URL(string: KoKoAPI.Endpoint.getUserData.urlString) else {
            throw APIError.invalidUrl
        }

        let request = APIRequest(url: url, method: .get)

        return try await self.send(request: request)
    }

    /// 取回好友資料
    func getFriendsData(scenario: Int) async throws -> GetFriendsResponse {

        guard let url = URL(string: KoKoAPI.Endpoint.getFriendsData(scenario: scenario).urlString) else { throw APIError.encodingError }

        let request = APIRequest(url: url, method: .get)

        return try await self.send(request: request)
    }

}
