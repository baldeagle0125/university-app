//
//  StudentIDPage.swift
//  UniversityAppPrototype
//
//  Created by Ihor Melashchenko on 31/10/2025.
//

import SwiftUI

struct StudentIDPage: View {
    @State private var flipped = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Student ID")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Spacer()
                
                ZStack {
                    StudentIDFront()
                        .opacity(flipped ? 0 : 1)
                    
                    StudentIDBack()
                        .opacity(flipped ? 1 : 0)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                .rotation3DEffect(
                    .degrees(flipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0
                )
                .animation(.easeInOut(duration: 0.6), value: flipped)
                .onTapGesture {
                    flipped.toggle()
                }
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Text("Scan")
                    .font(.title2)
                    .padding()
                    .glassEffect(.regular.interactive())
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Gradient(colors: backgroundColor))
    }
}

#Preview {
    StudentIDPage()
}
