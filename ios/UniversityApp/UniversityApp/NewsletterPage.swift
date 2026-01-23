//
//  NewsletterPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct NewsletterPage: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Newsletter")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TabView {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 150)
                        .opacity(0.3)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                    
                    Text("News Item 1")
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 150)
                        .opacity(0.3)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                    
                    Text("News Item 2")
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 150)
                        .opacity(0.3)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                    
                    Text("News Item 3")
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 150)
                        .opacity(0.3)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                    
                    Text("News Item 4")
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 150)
                        .opacity(0.3)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                    
                    Text("News Item 5")
                }
            }
            .tabViewStyle(.page)
            
            Text("Favorites")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 150)
                            .opacity(0.3)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                        
                        VStack {
                            Image(systemName: "books.vertical")
                            
                            Text("Courses")
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 150)
                            .opacity(0.3)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                        
                        VStack {
                            Image(systemName: "gym.bag")
                            
                            Text("Gym")
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 150)
                            .opacity(0.3)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                        
                        VStack {
                            Image(systemName: "hand.raised.palm.facing")
                            
                            Text("Voting")
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 150)
                            .opacity(0.3)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                        
                        VStack {
                            Image(systemName: "person.3")
                            
                            Text("Channels")
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }
        }
        .padding()
        .background(Gradient(colors: backgroundColor))
    }
}

#Preview {
    NewsletterPage()
}
