//
//  StudentIDFront.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct StudentIDFront: View {
    let student: Student?
    var hasPendingRequest: Bool = false
    
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
            
            if let status = student?.cardStatus {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        statusBadge(status: status, hasPendingRequest: hasPendingRequest)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
                .frame(width: 325, height: 500)
            }
        }
    }
    
    @ViewBuilder
    private func statusBadge(status: String, hasPendingRequest: Bool) -> some View {
        let (icon, color, text) = determineBadgeInfo(status: status, hasPendingRequest: hasPendingRequest)
        
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color)
        .foregroundStyle(.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
    
    private func determineBadgeInfo(status: String, hasPendingRequest: Bool) -> (icon: String, color: Color, text: String) {
        if status.lowercased() == "lost" {
            if hasPendingRequest {
                return ("exclamationmark.triangle.fill", .orange, "Lost – Pending")
            } else {
                return ("xmark.circle.fill", .red, "Lost")
            }
        }
        
        if hasPendingRequest {
            return ("clock.fill", .orange, "Pending Request")
        }
        
        return statusInfo(status: status)
    }
    
    private func statusInfo(status: String) -> (icon: String, color: Color, text: String) {
        switch status.lowercased() {
        case "active":
            return ("checkmark.circle.fill", .green, "Active")
        case "expired":
            return ("exclamationmark.triangle.fill", .red, "Expired")
        case "lost":
            return ("xmark.circle.fill", .red, "Lost")
        case "pending":
            return ("clock.fill", .orange, "Pending")
        default:
            return ("questionmark.circle.fill", .gray, status.capitalized)
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
