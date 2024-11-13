//
//  HTTPResponse.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/8.
//

import Foundation

protocol APIResponse: Decodable {
//    var success: Bool { get }
//    var message: String { get }
}




struct GetUserDataResponse: APIResponse {
//    var success: Bool
//    var message: String
    var response: [UserData]?
}

struct UserData: Decodable {
    let name: String
    let kokoid: String
}

struct GetFriendResponse: APIResponse {
    var success: Bool
    var message: String
}

struct Friend: Decodable {
    let name: String
    let status: Int
    let isTop: Bool
    let fid: String
    let updateDate: String
}
