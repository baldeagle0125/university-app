//
//  ServiceCard.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 16/02/2026.
//

import SwiftUI

struct ServiceCard: View {
    let service: Service
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 150)
                .opacity(service.isAvailable ? 0.3 : 0.15)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
       
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: service.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(service.isAvailable ? .primary : .secondary)
                    
                    if !service.isAvailable {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 16))
                            .fontWeight(.heavy)
                            .foregroundStyle(.orange)
                            .padding(4)
                            .background(Circle().fill(.black))
                            .offset(x: 35, y: -10)
                    }
                }
                
                Text(service.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(service.isAvailable ? .primary : .secondary)
                
                if !service.isAvailable {
                    Text("Coming Soon")
                        .font(.system(size: 11))
                        .fontWeight(.heavy)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(.black))
                }
            }
            .padding()
        }
        .opacity(service.isAvailable ? 1.0 : 0.7)
    }
}

#Preview {
    ServiceCard(service: Service(icon: "calendar", title: "Timetable", isAvailable: false))
}
