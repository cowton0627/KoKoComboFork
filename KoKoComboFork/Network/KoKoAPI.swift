//
//  KoKoAPI.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/12.
//

import Foundation

struct KoKoAPI {
    
    static var rootEndpoint: String { "https://dimanyen.github.io/" }
    
    /// Senario
    /// - 1：好友列表一，status 有 0、1、2
    /// - 2：好友列表二，status 僅有 1
    /// - 3：好友列表三，status 有 0、1、2
    /// - 4：好友列表四，空
//    static var scenario = 1
    
    enum Endpoint {
        case getUserData
        case getFriendsData(scenario: Int)
        
        var urlString: String {
            switch self {
            case .getUserData:
                return "\(KoKoAPI.rootEndpoint)man.json"
            case .getFriendsData(let scenario) :
                return "\(KoKoAPI.rootEndpoint)friend\(scenario).json"
            }
        }
    }
    
}
