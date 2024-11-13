//
//  KoKoAPI.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/12.
//

import Foundation

struct KoKoAPI {
    
    static var rootEndpoint: String { "https://dimanyen.github.io/" }
    
    enum Endpoint {
        case getUserData
        
        var urlString: String {
            switch self {
            case .getUserData:
                return "\(KoKoAPI.rootEndpoint)man.json"
            }
        }
    }
    
}
