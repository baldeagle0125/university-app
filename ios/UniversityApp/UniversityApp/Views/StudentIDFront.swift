//
//  StudentIDFront.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct StudentIDFront: View {
    let student: Student?
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 40)
                .frame(width: 325, height: 500)
                .opacity(0.3)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 40))
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 40)
                            .frame(width: 150, height: 180)
                            .opacity(0.3)
                        
                        if let photoURL = student?.profilePhotoUrlObject {
                            AsyncImage(url: photoURL) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.gray)
                            }
                            .frame(width: 150, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 125, height: 75)
                                .foregroundStyle(.white)
                            
                            Image("UniversityLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 125, height: 75)
                                .aspectRatio(contentMode: .fit)
                        }
                        
                        Text(student?.studentNumber ?? "SETU000001")
                            .font(.title3)
                            .fontWeight(.bold)
                            .redacted(reason: student == nil ? .placeholder : [])
                    }
                }
                
                Spacer()
                    
                VStack(alignment: .leading) {
                    Text(student?.programCode ?? "CW_KCSOF_B")
                        .font(.title2)
                        .redacted(reason: student == nil ? .placeholder : [])
                    
                    Text("Issued \(formatDate(date: student?.cardIssuedDateObject))")
                        .font(.title3)
                        .italic()
                        .redacted(reason: student == nil ? .placeholder : [])
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(student?.firstName ?? "Alex")
                        .font(.title)
                        .fontWeight(.bold)
                        .redacted(reason: student == nil ? .placeholder : [])
                    
                    Text(student?.lastName ?? "Murphy")
                        .font(.title)
                        .fontWeight(.bold)
                        .redacted(reason: student == nil ? .placeholder : [])
                }
            }
            .padding(20)
            .frame(width: 325, height: 500)
        }
    }
    
    private func formatDate(date: Date?) -> String {
        guard let date = date else {
            return "01/09/2025"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        return formatter.string(from: date)
    }
}

#Preview {
    StudentIDFront(student: nil)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Gradient(colors: backgroundColor))
}
