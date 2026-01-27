//
//  NetworkService.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 27/01/2026.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL: String = "http://localhost:3333"
    
    private init() {}
    
    func login(studentNumber: String, password: String) async throws -> String {
        return ""
    }
}
