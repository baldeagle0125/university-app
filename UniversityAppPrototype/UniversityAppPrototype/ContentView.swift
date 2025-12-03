//
//  ContentView.swift
//  UniversityAppPrototype
//
//  Created by Ihor Melashchenko on 31/10/2025.
//

import SwiftUI

let backgroundColor: [Color] = [
    .backgroundColor1,
    .backgroundColor2,
    .backgroundColor3,
    .backgroundColor4
]

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Newsletter", systemImage: "newspaper") {
                NewsletterPage()
            }
            Tab("Student ID", systemImage: "person.text.rectangle") {
                StudentIDPage()
            }
            Tab("Services", systemImage: "square.grid.2x2") {
                ServicesPage()
            }
            Tab("Profile", systemImage: "person") {
                ProfilePage()
            }
        }
        .background(Gradient(colors: backgroundColor))
    }
}

#Preview {
    ContentView()
}
