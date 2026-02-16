//
//  ServicesPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct ServicesPage: View {
    let services: [Service] = [
        Service(icon: "calendar", title: "Timetable", isAvailable: true),
        Service(icon: "map", title: "Campus Map", isAvailable: false),
        Service(icon: "books.vertical", title: "Courses", isAvailable: false),
        Service(icon: "gym.bag", title: "Gym", isAvailable: false),
        Service(icon: "hand.raised.palm.facing", title: "Voting", isAvailable: false),
        Service(icon: "person.3", title: "Channels", isAvailable: false),
        Service(icon: "fork.knife", title: "Canteen", isAvailable: false),
        Service(icon: "book.closed", title: "Library", isAvailable: false),
        Service(icon: "bus", title: "Transport", isAvailable: false),
        Service(icon: "eurosign.circle", title: "Payments", isAvailable: false)
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Services")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(height: 50)
                        .opacity(0.3)
                        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        
                        Text("Search")
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "microphone")
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                }
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(services) { service in
                        ServiceCard(service: service)
                    }
                }
                .padding(.top, 10)
            }
            .padding(30)
        }
        .background(Gradient(colors: backgroundColor))
    }
}

#Preview {
    ServicesPage()
}
