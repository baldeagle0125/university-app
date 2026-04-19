//
//  LoginPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var studentNumber: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                TextField("Student Number", text: $studentNumber)
                    .padding(15)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    .disabled(isLoading)
                
                SecureField("Password", text: $password)
                    .padding(15)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    .disabled(isLoading)
                
                HStack {
                    Spacer()
                    
                    Button {
                        handleLogin()
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Login")
                                .font(.title2)
                        }
                    }
                    .padding()
                    .frame(width: 100, height: 50)
                    .glassEffect(.regular.interactive())
                    .disabled(isLoading || studentNumber.isEmpty || password.isEmpty)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding()
                        .glassEffect(.regular.interactive())
                    }
                    .disabled(isLoading)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Gradient(colors: backgroundColor))
            .navigationDestination(isPresented: $authViewModel.isAuthenticated) {
                MainTabView().navigationBarBackButtonHidden()
            }
            .alert("Login Failed", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(authViewModel.errorMessage ?? "Unknown error occurred")
            }
            .onChange(of: authViewModel.errorMessage) { oldValue, newValue in
                if newValue != nil {
                    showAlert = true
                    password = ""
                }
            }
        }
    }
    
    private func handleLogin() {
        isLoading = true
        
        Task {
            await authViewModel.login(studentNumber: studentNumber, password: password)
            isLoading = false
        }
    }
}

#Preview {
    LoginPage()
        .environmentObject(AuthViewModel())
}
