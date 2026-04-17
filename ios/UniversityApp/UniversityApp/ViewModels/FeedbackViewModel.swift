//
//  FeedbackViewModel.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 17/04/2026.
//

import Foundation
import Combine

@MainActor
class FeedbackViewModel: ObservableObject {
    @Published var feedbackType: String = "bug"
    @Published var rating: Int = 4
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var affectedArea: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let networkService = NetworkService.shared

    var canSubmit: Bool {
        let hasCoreFields = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if feedbackType == "usability" {
            return hasCoreFields && (1...5).contains(rating)
        }

        return hasCoreFields
    }

    var ratingPayload: Int? {
        feedbackType == "usability" ? rating : nil
    }

    func trackOpen() async {
        await trackEvent(
            name: "feedback_page_opened",
            category: "feedback",
            context: ["entry_point": "profile"]
        )
    }

    func submitFeedback() async -> Bool {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        await trackEvent(
            name: "feedback_submit_attempt",
            category: "feedback",
            context: ["feedback_type": feedbackType]
        )

        do {
            _ = try await networkService.submitFeedback(
                feedbackType: feedbackType,
                rating: ratingPayload,
                title: title,
                message: message,
                affectedArea: affectedArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : affectedArea
            )

            successMessage = "Thank you. Your feedback has been submitted."

            await trackEvent(
                name: "feedback_submit_success",
                category: "feedback",
                context: ["feedback_type": feedbackType]
            )

            resetForm()
            isLoading = false
            return true
        } catch let error as NetworkError {
            errorMessage = error.errorDescription

            await trackEvent(
                name: "feedback_submit_failed",
                category: "feedback",
                context: [
                    "feedback_type": feedbackType,
                    "error": error.errorDescription ?? "unknown"
                ]
            )

            isLoading = false
            return false
        } catch {
            errorMessage = "Failed to submit feedback"

            await trackEvent(
                name: "feedback_submit_failed",
                category: "feedback",
                context: [
                    "feedback_type": feedbackType,
                    "error": "unknown"
                ]
            )

            isLoading = false
            return false
        }
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    private func resetForm() {
        feedbackType = "bug"
        rating = 4
        title = ""
        message = ""
        affectedArea = ""
    }

    private func trackEvent(name: String, category: String, context: [String: String]) async {
        do {
            try await networkService.trackTelemetryEvent(
                eventName: name,
                eventCategory: category,
                contextPayload: context,
                screenName: "feedback_page"
            )
        } catch {
            // Telemetry must not block UX flows.
        }
    }
}
