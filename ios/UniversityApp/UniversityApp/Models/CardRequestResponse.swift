//
//  CardRequestResponse.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 16/02/2026.
//

import Foundation

struct CardRequestResponse: Codable, Identifiable {
    let id: Int
    let studentNumber: String
    let requestType: String
    let requestReason: String?
    let requestStatus: String
    let requestedAt: String
    let processedAt: String?
    let processedBy: String?
    let adminNotes: String?
    let createdAt: String
    let updatedAt: String
    
    var requestedDate: Date? {
        let formatter = ISO8601DateFormatter()
        
        return formatter.date(from: requestedAt)
    }
    
    var statusColor: String {
        switch requestStatus {
        case "pending":
            return "blue"
        case "approved":
            return "green"
        case "rejected":
            return "red"
        default:
            return "gray"
        }
    }
    
    var typeDisplayName: String {
        switch requestType {
        case "new":
            return "New Card"
        case "replacement":
            return "Replacement"
        case "lost":
            return "Lost Card"
        default :
            return requestType
        }
    }
}

struct CardRequestStatusResponse: Codable {
    let hasRequest: Bool
    let request: CardRequestResponse?
    let message: String?
}
