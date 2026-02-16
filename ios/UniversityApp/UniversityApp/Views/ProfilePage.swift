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
    @State private var showCardManagement: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button {
                showCardManagement = true
            } label: {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("Card Management")
                            .font(.headline)
                        
                        Text("Request or replace your student card")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
            .foregroundStyle(.primary)
            
            Spacer()
            
            Button {
                showLogoutAlert = true
            } label: {
                Text("Logout")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .glassEffect(.regular.interactive())
            .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Gradient(colors: backgroundColor))
        .alert("Logout?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            Button("Logout", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .sheet(isPresented: $showCardManagement) {
            CardManagementPage()
        }
    }
}

#Preview {
    ProfilePage()
        .environmentObject(AuthViewModel())
}
