//
//  ServicesPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct ServicesPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Services")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 350, height: 50)
                        .opacity(0.3)
                        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text("Search")
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Spacer()
                        
                        Spacer()
                        
                        Spacer()
                        
                        Spacer()
                        
                        Spacer()
                        
                        Image(systemName: "microphone")
                            .foregroundStyle(.gray)
                    }
                    .padding()
                }
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 150)
                            .opacity(0.3)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                        
                        VStack {
                            Image(systemName: "calendar")
                            
                            Text("Timetable")
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 150)
                            .opacity(0.3)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                        
                        VStack {
                            Image(systemName: "map")
                            
                            Text("Campus Map")
                        }
                    }
                }
                
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
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 150)
                            .opacity(0.3)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                        
                        VStack {
                            Image(systemName: "calendar")
                            
                            Text("Timetable")
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 150, height: 150)
                            .opacity(0.3)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                        
                        VStack {
                            Image(systemName: "map")
                            
                            Text("Campus Map")
                        }
                    }
                }
                
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
            }
            .padding(30)
        }
        .background(Gradient(colors: backgroundColor))
    }
}

#Preview {
    ServicesPage()
}
