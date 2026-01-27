//
//  AuthViewModel.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 27/01/2026.
//

import Foundation

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isAuthenticated = AuthService.shared.checkIfTokenExists()
    }
    
    func login(studentNumber: String, password: String) async {
        if NetworkService.login(studentNumber: studentNumber, password: password) {
            
        }
    }
    
    func logout() {
        AuthService.shared.deleteToken()
        isAuthenticated = false
    }
}
