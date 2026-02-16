//
//  WelcomePage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct WelcomePage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let features: [FeatureItem] = [
        FeatureItem(title: "Digital Student ID", description: "Your student ID card is now digital and can be accessed from your phone. No need to carry around plastic IDs anymore.", icon: "person.text.rectangle", gradient: [.blue, .purple]),
        FeatureItem(title: "Campus Services", description: "Access all university services in one single application. From academic support to health and wellness, we've got you covered.", icon: "building.2", gradient: [.purple, .pink]),
        FeatureItem(title: "Real-Time Updates", description: "Stay informed with instant notifications about campus news, events, and important announcements.", icon: "bell.badge", gradient: [.orange, .red]),
        FeatureItem(title: "QR Code Scanning", description: "Quick access to campus facilities and services with secure QR code authentication.", icon: "qrcode", gradient: [.green, .teal]),
        FeatureItem(title: "Personalized Experience", description: "Customize your dashboard with your favorite services and stay connected with your community.", icon: "heart.circle", gradient: [.pink, .purple])
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, -50)
                
                TabView() {
                    ForEach(features) { feature in
                        FeatureCard(feature: feature)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                HStack {
                    Spacer()
                    
                    NavigationLink(destination: LoginPage()) {
                        Text("Continue")
                            .font(.title2)
                            .padding()
                            .glassEffect(.regular.interactive())
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Gradient(colors: backgroundColor))
        }
    }
}

#Preview {
    WelcomePage().environmentObject(AuthViewModel())
}
