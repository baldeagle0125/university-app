//
//  ServicesPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct ServicesPage: View {
    @State private var showAssignmentTracker: Bool = false

    let services: [Service] = [
        Service(icon: "doc.text", title: "Assignments", isAvailable: true),
        Service(icon: "calendar", title: "Timetable", isAvailable: false),
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
        VStack(alignment: .leading, spacing: 20) {
            Text("Services")
                .font(.largeTitle)
                .fontWeight(.bold)

            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .frame(height: 50)
                    .opacity(0.3)

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
            }
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(services) { service in
                        if service.isAvailable && service.title == "Assignments" {
                            Button {
                                showAssignmentTracker = true
                            } label: {
                                ServiceCard(service: service)
                            }
                            .buttonStyle(.plain)
                        } else {
                            ServiceCard(service: service)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(30)
        .background(Gradient(colors: backgroundColor))
        .sheet(isPresented: $showAssignmentTracker) {
            AssignmentTrackerPage()
        }
    }
}

#Preview {
    ServicesPage()
}
