//
//  NewsItem.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 16/02/2026.
//

import Foundation

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
