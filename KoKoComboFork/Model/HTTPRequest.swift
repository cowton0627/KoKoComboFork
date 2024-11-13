//
//  HTTPRequest.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/12.
//

import Foundation

enum HttpMethod: String {
    case post   = "POST"
    case get    = "GET"
    case put    = "PUT"
    case delete = "DELETE"
}

struct APIRequest {
    let url: URL
    let method: HttpMethod
}
