//
//  Student.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 27/01/2026.
//

import Foundation

struct Student: Codable {
    let id: Int
    let studentNumber: String
    let firstName: String
    let lastName: String
    let email: String
    let programCode: String?
    let cardIssuedDate: String?
    let cardExpiryDate: String?
    let profilePhotoUrl: String?
    let cardStatus: String
    let createdAt: String
    let updatedAt: String
    
    var cardIssuedDateObject: Date? {
        guard let dateString = cardIssuedDate else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.date(from: dateString)
    }
    
    var profilePhotoUrlObject: URL? {
        guard let urlString = profilePhotoUrl else {
            return nil
        }
        
        return URL(string: urlString)
    }
}
