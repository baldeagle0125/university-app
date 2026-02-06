//
//  UniversityAppApp.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

@main
struct UniversityAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                WelcomePage()
                    .environmentObject(authViewModel)
            }
        }
    }
}
