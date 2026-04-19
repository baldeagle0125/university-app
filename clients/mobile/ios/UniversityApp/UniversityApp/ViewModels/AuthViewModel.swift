//
//  AuthViewModel.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 27/01/2026.
//

import Foundation
import Combine

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
        errorMessage = nil
        
        do {
            let token = try await NetworkService.shared.login(studentNumber: studentNumber, password: password)
            AuthService.shared.saveToken(token: token)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
    }
    
    func logout() {
        AuthService.shared.deleteToken()
        isAuthenticated = false
    }
}
