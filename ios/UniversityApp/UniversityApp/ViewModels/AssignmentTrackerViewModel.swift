//
//  AssignmentTrackerViewModel.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 17/04/2026.
//

import Foundation
import Combine

@MainActor
class AssignmentTrackerViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let networkService = NetworkService.shared

    func fetchAssignments() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedAssignments = try await networkService.getAssignments()
            if fetchedAssignments.isEmpty {
                assignments = fallbackAssignments()
            } else {
                assignments = fetchedAssignments
            }
        } catch let error as NetworkError {
            assignments = fallbackAssignments()
            errorMessage = "Showing demo assignments. \(error.errorDescription ?? "")"
        } catch {
            assignments = fallbackAssignments()
            errorMessage = "Showing demo assignments. Failed to load assignments"
        }

        isLoading = false
    }

    func submitAssignment(assignmentID: Int, submissionText: String) async -> Bool {
        let trimmedSubmissionText = submissionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSubmissionText.isEmpty else {
            errorMessage = "Submission text is required"

            return false
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let updatedAssignment = try await networkService.submitAssignmentText(assignmentId: assignmentID, submissionText: trimmedSubmissionText)

            if let index = assignments.firstIndex(where: { $0.id == updatedAssignment.id }) {
                assignments[index] = updatedAssignment
            } else {
                assignments.append(updatedAssignment)
            }

            successMessage = "Assignment submitted successfully"
            isLoading = false

            return true
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
            isLoading = false

            return false
        } catch {
            errorMessage = "Failed to submit assignment"
            isLoading = false

            return false
        }
    }

    var upcomingAssignments: [Assignment] {
        assignments
            .filter { !$0.isSubmitted && !$0.isOverdue && !$0.isDueSoon }
            .sorted { $0.daysUntilDue < $1.daysUntilDue }
    }

    var dueSoonAssignments: [Assignment] {
        assignments
            .filter { !$0.isSubmitted && $0.isDueSoon && !$0.isOverdue }
            .sorted { $0.daysUntilDue < $1.daysUntilDue }
    }

    var overdueAssignments: [Assignment] {
        assignments
            .filter { !$0.isSubmitted && $0.isOverdue }
            .sorted { $0.daysUntilDue < $1.daysUntilDue }
    }

    var submittedAssignments: [Assignment] {
        assignments
            .filter { $0.isSubmitted }
            .sorted {
                ($0.submittedAtObject ?? .distantPast) > ($1.submittedAtObject ?? .distantPast)
            }
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    private func fallbackAssignments() -> [Assignment] {
        let formatter = ISO8601DateFormatter()
        let now = Date()

        let assignment1DueDate = formatter.string(from: now.addingTimeInterval(2 * 24 * 60 * 60))
        let assignment2DueDate = formatter.string(from: now.addingTimeInterval(5 * 24 * 60 * 60))
        let assignment3DueDate = formatter.string(from: now.addingTimeInterval(-1 * 24 * 60 * 60))

        return [
            Assignment(
                id: -1,
                studentNumber: "demo",
                title: "Database Design Report",
                description: "Submit ERD and normalization analysis for the student portal system.",
                dueDate: assignment1DueDate,
                status: "assigned",
                daysUntilDue: 2,
                isOverdue: false,
                submissionText: nil,
                submittedAt: nil,
                createdAt: formatter.string(from: now),
                updatedAt: formatter.string(from: now)
            ),
            Assignment(
                id: -2,
                studentNumber: "demo",
                title: "Operating Systems Lab",
                description: "Upload lab notes and process scheduling screenshots.",
                dueDate: assignment2DueDate,
                status: "assigned",
                daysUntilDue: 5,
                isOverdue: false,
                submissionText: nil,
                submittedAt: nil,
                createdAt: formatter.string(from: now),
                updatedAt: formatter.string(from: now)
            ),
            Assignment(
                id: -3,
                studentNumber: "demo",
                title: "Linear Algebra Problem Set",
                description: "Complete tasks 1-10 from chapter 4.",
                dueDate: assignment3DueDate,
                status: "overdue",
                daysUntilDue: -1,
                isOverdue: true,
                submissionText: nil,
                submittedAt: nil,
                createdAt: formatter.string(from: now),
                updatedAt: formatter.string(from: now)
            )
        ]
    }
}
