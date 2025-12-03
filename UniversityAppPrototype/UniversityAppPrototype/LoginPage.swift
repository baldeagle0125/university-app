//
//  LoginPage.swift
//  UniversityAppPrototype
//
//  Created by Ihor Melashchenko on 31/10/2025.
//

import SwiftUI

struct LoginPage: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 350, height: 50)
                        .opacity(0.3)
                        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    
                    Text("Student ID")
                        .foregroundStyle(.gray)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 350, height: 50)
                        .opacity(0.3)
                        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    
                    Text("Password")
                        .foregroundStyle(.gray)
                }
                
                NavigationLink(destination: ContentView()) {
                    Text("Login")
                        .font(.title2)
                        .padding()
                        .glassEffect(.regular.interactive())
                }
                
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
