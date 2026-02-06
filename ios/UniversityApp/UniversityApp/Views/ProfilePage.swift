//
//  ProfilePage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct ProfilePage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showLogoutAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button {
                authViewModel.logout()
            } label: {
                Text("Logout")
                    .font(.title2)
            }
            .padding()
            .glassEffect(.regular.interactive())
            .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Gradient(colors: backgroundColor))
        .alert("Logout?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout") {
                authViewModel.logout()
            }
        }
    }
}

#Preview {
    ProfilePage()
}
