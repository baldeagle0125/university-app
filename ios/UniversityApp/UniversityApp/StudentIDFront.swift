//
//  StudentIDFront.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct StudentIDFront: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 40)
                .frame(width: 325, height: 500)
                .opacity(0.3)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 40))
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 40)
                        .frame(width: 150, height: 180)
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 125, height: 75)
                            .foregroundStyle(.white)
                        
                        Text("C00290950")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                    
                VStack(alignment: .leading) {
                    Text("CW_KCSOF_B")
                        .font(.title2)
                    
                    Text("Issued 12/09/2022")
                        .font(.title2)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Ihor")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Melashchenko")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .padding(20)
            .frame(width: 325, height: 500)
        }
    }
}

#Preview {
    StudentIDFront()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Gradient(colors: backgroundColor))
}
