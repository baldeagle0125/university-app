//
//  WelcomePage.swift
//  UniversityAppPrototype
//
//  Created by Ihor Melashchenko on 31/10/2025.
//

import SwiftUI

struct WelcomePage: View {
    var body: some View {
        NavigationView {
            VStack() {
                HStack {
                    Text("Welcome")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                TabView() {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 350, height: 500)
                            .opacity(0.3)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                        
                        Text("Feature 1")
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 350, height: 500)
                            .opacity(0.3)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                        
                        Text("Feature 2")
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 350, height: 500)
                            .opacity(0.3)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                        
                        Text("Feature 3")
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 350, height: 500)
                            .opacity(0.3)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                        
                        Text("Feature 4")
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 350, height: 500)
                            .opacity(0.3)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                        
                        Text("Feature 5")
                    }
                    
                }
                .tabViewStyle(.page)
                
                NavigationLink(destination: LoginPage()) {
                    Text("Continue")
                        .font(.title2)
                        .padding()
                        .glassEffect(.regular.interactive())
                }
            }
            .padding()
            .background(Gradient(colors: backgroundColor))
        }
    }
}

#Preview {
    WelcomePage()
}
