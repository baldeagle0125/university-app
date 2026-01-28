//
//  NetworkService.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 27/01/2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case unathorized
    case serverError(Int)
    case decodingError
}

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL: String = "http://localhost:3333"
    
    private init() {}
    
    func login(studentNumber: String, password: String) async throws -> String {
        let urlString: String = "\(baseURL)/api/v1/login"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(studentNumber: studentNumber, password: password)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        
        let jsonData = try jsonEncoder.encode(loginRequest)
        
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unathorized
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let loginResponse = try jsonDecoder.decode(LoginResponse.self, from: data)
        
        return loginResponse.token
    }
}
