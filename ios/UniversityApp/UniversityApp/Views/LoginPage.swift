//
//  LoginPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct LoginPage: View {
    @State private var studentNumber: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var isLoggedIn: Bool = false
    
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
                
                SecureField("Password", text: $password)
                    .padding(15)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                
                Button("Login") {
                    
                }
                .padding()
                .glassEffect(.regular.interactive())
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Gradient(colors: backgroundColor))
        }
    }
}

#Preview {
    LoginPage()
}
