//
//  AuthService.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 27/01/2026.
//

import Foundation

// UserDefaults
/*
UserDefaults.standard.set("value", forKey: "key")
let value = UserDefaults.standard.string(forKey: "key")
UserDefaults.standard.removeObject(forKey: "key")
*/


class AuthService {
    static let shared = AuthService()
    private let tokenKey = "authToken"
    
    private init() {}
    
    func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }

    func deleteToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }

    func checkIfTokenExists() -> Bool {
        return getToken() != nil
    }
}
