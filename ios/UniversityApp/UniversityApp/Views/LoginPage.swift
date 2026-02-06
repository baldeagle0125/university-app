//
//  LoginPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var studentNumber: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                Spacer()
                
                TextField("Student Number", text: $studentNumber)
                    .padding(15)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    .disabled(isLoading)
                
                SecureField("Password", text: $password)
                    .padding(15)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    .disabled(isLoading)
                
                Button {
                    handleLogin()
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Login")
                            .font(.title2)
                    }
                }
                .padding()
                .glassEffect(.regular.interactive())
                .disabled(isLoading || studentNumber.isEmpty || password.isEmpty)
                
                Spacer()
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
