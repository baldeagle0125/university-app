//
//  NewsCard.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 16/02/2026.
//

import SwiftUI

struct NewsCard: View {
    let newsItem: NewsItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 350, height: 150)
                .opacity(0.3)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(newsItem.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(newsItem.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(newsItem.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                
                Spacer()
            }
            .padding()
            .frame(width: 350, height: 135)
        }
    }
}

#Preview {
    NewsCard(newsItem: NewsItem(title: "Annual Student Survey", description: "This survey is aimed at gathering feedback on the student life and services provided by the university.", date: Date()))
}
