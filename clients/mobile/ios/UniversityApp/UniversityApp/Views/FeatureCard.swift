//
//  FeatureCard.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 16/02/2026.
//

import SwiftUI

struct FeatureCard: View {
    let feature: FeatureItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 350, height: 500)
                .opacity(0.3)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: feature.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: feature.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(feature.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(width: 350, height: 500)
        }
    }
}

#Preview {
    FeatureCard(feature: FeatureItem(title: "Digital Student ID", description: "Your student ID card is now digital and can be accessed from your phone. No need to carry around plastic IDs anymore.", icon: "person.text.rectangle", gradient: [.blue, .purple]))
}
