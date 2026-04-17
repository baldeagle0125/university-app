//
//  Assignment.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 17/04/2026.
//

import Foundation

struct Assignment: Codable, Identifiable {
    let id: Int
    let studentNumber: String
    let title: String
    let description: String?
    let dueDate: String
    let status: String
    let daysUntilDue: Int
    let isOverdue: Bool
    let submissionText: String?
    let submittedAt: String?
    let createdAt: String
    let updatedAt: String

    var dueDateObject: Date? {
        let formatter = ISO8601DateFormatter()

        return formatter.date(from: dueDate)
    }

    var submittedAtObject: Date? {
        guard let submittedAt else {
            return nil
        }

        let formatter = ISO8601DateFormatter()

        return formatter.date(from: submittedAt)
    }

    var isSubmitted: Bool {
        status.lowercased() == "submitted"
    }

    var statusDisplayName: String {
        switch status.lowercased() {
        case "submitted":
            return "Submitted"
        case "overdue":
            return "Overdue"
        case "assigned":
            return "Assigned"
        default:
            return status.capitalized
        }
    }

    var reminderText: String {
        if isSubmitted {
            if let submittedAtObject {
                return "Submitted \(submittedAtObject.formatted(date: .abbreviated, time: .shortened))"
            }

            return "Submitted"
        }

        if isOverdue {
            let overdueDays = max(1, abs(daysUntilDue))

            return "Overdue by \(overdueDays) day\(overdueDays == 1 ? "" : "s")"
        }

        if daysUntilDue == 0 {
            return "Due today"
        }

        if daysUntilDue == 1 {
            return "Due tomorrow"
        }

        return "Due in \(daysUntilDue) days"
    }

    var isDueSoon: Bool {
        !isSubmitted && !isOverdue && daysUntilDue <= 2
    }
}

struct SubmitAssignmentRequest: Codable {
    let submissionText: String
}
