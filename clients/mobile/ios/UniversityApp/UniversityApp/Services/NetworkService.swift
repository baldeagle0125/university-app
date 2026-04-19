//
//  NetworkService.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 27/01/2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case serverErrorMessage(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Invalid student number or password"
        case .serverError(let code):
            return "Server error (Code: \(code))"
        case .serverErrorMessage(let message):
            return message
        case .decodingError:
            return "Failed to process server response"
        }
    }
}

private struct APIErrorResponse: Codable {
    let error: String
}

private struct CreateCardRequestPayload: Codable {
    let requestType: String
    let requestReason: String
}

class NetworkService {
    static let shared = NetworkService()

    private let baseURL: String = AppConfig.baseURL

    private init() {}

    func login(studentNumber: String, password: String) async throws -> String {
        let urlString = "\(baseURL)/api/v1/login"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginRequest = LoginRequest(studentNumber: studentNumber, password: password)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(loginRequest)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let loginResponse = try decoder.decode(LoginResponse.self, from: data)
            return loginResponse.token
        } catch {
            throw NetworkError.decodingError
        }
    }

    func fetchProfile() async throws -> Student {
        let urlString = "\(baseURL)/api/v1/student-info"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        try attachAuthorization(to: &request)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(Student.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func fetchQRCode() async throws -> CodeResponse {
        try await fetchCodeResponse(path: "/api/v1/qr-code")
    }

    func fetchBarcode() async throws -> CodeResponse {
        try await fetchCodeResponse(path: "/api/v1/barcode")
    }

    func verifyCode(token: String) async throws -> VerifyResponse {
        let urlString = "\(baseURL)/api/v1/verify"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(VerifyRequest(token: token))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(VerifyResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func createCardRequest(requestType: String, requestReason: String) async throws -> CardRequestResponse {
        let urlString = "\(baseURL)/api/v1/card/requests"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try attachAuthorization(to: &request)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(
            CreateCardRequestPayload(requestType: requestType, requestReason: requestReason)
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 201:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(CardRequestResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func getCardRequests() async throws -> [CardRequestResponse] {
        let urlString = "\(baseURL)/api/v1/card/requests"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        try attachAuthorization(to: &request)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode([CardRequestResponse].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func getCardRequestStatus() async throws -> CardRequestStatusResponse {
        let urlString = "\(baseURL)/api/v1/card/status"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        try attachAuthorization(to: &request)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(CardRequestStatusResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func submitFeedback(
        feedbackType: String,
        rating: Int?,
        title: String,
        message: String,
        affectedArea: String?
    ) async throws -> FeedbackResponse {
        let urlString = "\(baseURL)/api/v1/feedback"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try attachAuthorization(to: &request)

        let body = FeedbackRequest(
            feedbackType: feedbackType,
            rating: rating,
            title: title,
            message: message,
            affectedArea: affectedArea
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 201:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(FeedbackResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func trackTelemetryEvent(
        eventName: String,
        eventCategory: String,
        contextPayload: [String: String]?,
        screenName: String?
    ) async throws {
        let urlString = "\(baseURL)/api/v1/telemetry/events"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try attachAuthorization(to: &request)

        let body = TelemetryEventRequest(
            eventName: eventName,
            eventCategory: eventCategory,
            contextPayload: contextPayload,
            screenName: screenName,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 201:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }
    }

    func getAssignments() async throws -> [Assignment] {
        let urlString = "\(baseURL)/api/v1/assignments"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        try attachAuthorization(to: &request)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode([Assignment].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func getAssignment(assignmentId: Int) async throws -> Assignment {
        let urlString = "\(baseURL)/api/v1/assignments/\(assignmentId)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        try attachAuthorization(to: &request)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(Assignment.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func submitAssignmentText(assignmentId: Int, submissionText: String) async throws -> Assignment {
        let urlString = "\(baseURL)/api/v1/assignments/\(assignmentId)/submit"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try attachAuthorization(to: &request)

        let body = SubmitAssignmentRequest(submissionText: submissionText)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(Assignment.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    private func fetchCodeResponse(path: String) async throws -> CodeResponse {
        let urlString = "\(baseURL)\(path)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        try attachAuthorization(to: &request)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw errorForResponse(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(CodeResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    private func attachAuthorization(to request: inout URLRequest) throws {
        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    private func errorForResponse(statusCode: Int, data: Data) -> NetworkError {
        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
           !apiError.error.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .serverErrorMessage(apiError.error)
        }

        if let message = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !message.isEmpty {
            return .serverErrorMessage(message)
        }

        return .serverError(statusCode)
    }
}
