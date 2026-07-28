//
//  APIService.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/12.
//

import Foundation

enum APIError: LocalizedError {
    case invalidUrl
    case encodingError
    case decodingError
    case serverError(Int)
    case networkError(Error)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "網址格式錯誤。"
        case .encodingError:
            return "無法建立請求資料。"
        case .decodingError:
            return "伺服器回傳了無法辨識的資料。"
        case .serverError(let statusCode):
            return "伺服器暫時無法處理請求（HTTP \(statusCode)）。"
        case .networkError:
            return "網路連線失敗，請確認連線後重試。"
        case .unknownError:
            return "發生未知錯誤，請稍後再試。"
        }
    }
}

class APIService {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send<T: APIResponse>(request: APIRequest,
                              body: APIBody? = nil) async throws -> T {

        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.encodingError
            }
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknownError
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}
