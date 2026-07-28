//
//  HTTPResponse.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/8.
//

import Foundation

protocol APIResponse: Decodable {}

// MARK: - API DTOs

struct GetUserDataResponseDTO: APIResponse {
    let response: [UserDataDTO]?
}

struct UserDataDTO: Decodable {
    let name: String
    let kokoid: String

    func toDomain() -> UserData {
        UserData(name: name, kokoid: kokoid)
    }
}

struct GetFriendsResponseDTO: APIResponse {
    let response: [FriendDTO]?
}

struct FriendDTO: Decodable {
    let name: String
    let status: Int
    let isTop: String
    let fid: String
    let updateDate: String

    func toDomain() -> Friend {
        Friend(
            name: name,
            status: FriendStatus(apiValue: status),
            isPinned: isTop == "1",
            fid: fid,
            updatedAt: FriendDateParser.parse(updateDate)
        )
    }
}

// MARK: - Domain models

struct GetUserDataResponse {
    let response: [UserData]?
}

struct UserData {
    let name: String
    let kokoid: String
}

struct GetFriendsResponse {
    let response: [Friend]?
}

enum FriendStatus: Equatable {
    case incomingInvitation
    case friend
    case outgoingInvitation
    case unknown(Int)

    init(apiValue: Int) {
        switch apiValue {
        case 0:
            self = .incomingInvitation
        case 1:
            self = .friend
        case 2:
            self = .outgoingInvitation
        default:
            self = .unknown(apiValue)
        }
    }
}

struct Friend {
    let name: String
    let status: FriendStatus
    let isPinned: Bool
    let fid: String
    let updatedAt: Date?
}

enum FriendDateParser {
    static func parse(_ value: String) -> Date? {
        let formats = ["yyyyMMdd", "yyyy/MM/dd"]

        for format in formats {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = format

            if let date = formatter.date(from: value) {
                return date
            }
        }

        return nil
    }
}
