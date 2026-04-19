//
//  FeedbackRequest.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 17/04/2026.
//

import Foundation

struct FeedbackRequest: Codable {
    let feedbackType: String
    let rating: Int?
    let title: String
    let message: String
    let affectedArea: String?
}

struct FeedbackResponse: Codable {
    let id: Int
    let studentNumber: String
    let feedbackType: String
    let rating: Int?
    let title: String
    let message: String
    let affectedArea: String?
    let createdAt: String
}

struct TelemetryEventRequest: Codable {
    let eventName: String
    let eventCategory: String
    let contextPayload: [String: String]?
    let screenName: String?
    let appVersion: String?
}

struct TelemetryEventResponse: Codable {
    let id: Int
    let studentNumber: String
    let eventName: String
    let eventCategory: String
    let contextPayload: [String: String]?
    let screenName: String?
    let appVersion: String?
    let createdAt: String
}
