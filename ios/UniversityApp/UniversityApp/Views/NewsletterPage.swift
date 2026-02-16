//
//  NewsletterPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct NewsletterPage: View {
    let newsItems: [NewsItem] = [
        NewsItem(title: "Annual Student Survey", description: "This survey is aimed at gathering feedback on the student life and services provided by the university.", date: Date().addingTimeInterval(-86400 * 2)),
        NewsItem(title: "Updated Library Hours", description: "The library will be closed on Tuesdays and Wednesdays from 12:00pm to 1:00pm.", date: Date().addingTimeInterval(-86400 * 5)),
        NewsItem(title: "Career Fair 2026", description: "The career fair will be taking place on Wednesday, 11th March 2026 from 10:00am to 4:00pm.", date: Date().addingTimeInterval(-86400 * 7)),
        NewsItem(title: "SAF Applications", description: "The SAF application deadline has passed. Please apply again by 26th February 2026.", date: Date().addingTimeInterval(-86400 * 10)),
        NewsItem(title: "New Bus Route", description: "New bus route has been created to the new campus building. Please check the timetable for updates.", date: Date().addingTimeInterval(-86400 * 12))
    ]
    
    let favoriteServices: [Service] = [
        Service(icon: "calendar", title: "Timetable", isAvailable: false),
        Service(icon: "map", title: "Campus Map", isAvailable: false),
        Service(icon: "books.vertical", title: "Courses", isAvailable: false),
        Service(icon: "gym.bag", title: "Gym", isAvailable: false)
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Newsletter")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, -50)
            
            TabView {
                ForEach(newsItems) { newsItem in
                    NewsCard(newsItem: newsItem)
                }
            }
            .tabViewStyle(.page)
            .frame(height: 270)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Spacer()
            
            Text("Favorites")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(favoriteServices) { service in
                    ServiceCard(service: service)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Gradient(colors: backgroundColor))
    }
}

#Preview {
    NewsletterPage()
}
