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

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL: String = AppConfig.baseURL
    
    private init() {}
    
    func login(studentNumber: String, password: String) async throws -> String {
        let urlString: String = "\(baseURL)/api/v1/login"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(studentNumber: studentNumber, password: password)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        
        let jsonData = try jsonEncoder.encode(loginRequest)
        request.httpBody = jsonData
        
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
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let loginResponse = try jsonDecoder.decode(LoginResponse.self, from: data)
        
        return loginResponse.token
    }
    
    func fetchProfile() async throws -> Student {
        let urlString: String = "\(baseURL)/api/v1/student-info"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let student = try jsonDecoder.decode(Student.self, from: data)
        
        return student
    }
    
    func fetchQRCode() async throws -> CodeResponse {
        let urlString: String = "\(baseURL)/api/v1/qr-code"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let codeResponse = try jsonDecoder.decode(CodeResponse.self, from: data)
        
        return codeResponse
    }
    
    func fetchBarcode() async throws -> CodeResponse {
        let urlString: String = "\(baseURL)/api/v1/barcode"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let codeResponse = try jsonDecoder.decode(CodeResponse.self, from: data)
        
        return codeResponse
    }
    
    func verifyCode(token: String) async throws -> VerifyResponse {
        let urlString: String = "\(baseURL)/api/v1/verify"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let verifyRequest = VerifyRequest(token: token)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        
        let jsonData = try jsonEncoder.encode(verifyRequest)
        request.httpBody = jsonData
        
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
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let verifyResponse = try jsonDecoder.decode(VerifyResponse.self, from: data)
        
        return verifyResponse
    }
    
    func createCardRequest(requestType: String, requestReason: String) async throws -> CardRequestResponse {
        let urlString: String = "\(baseURL)/api/v1/card/requests"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestBody = [
            "request_type": requestType,
            "request_reason": requestReason
        ]
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        
        let jsonData = try jsonEncoder.encode(requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 201:
            break
        case 400, 409:
            if let errorMessage = String(data: data, encoding: .utf8) {
                throw NetworkError.serverErrorMessage(errorMessage)
            }
            throw NetworkError.serverErrorMessage("Bad request")
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let cardRequest = try jsonDecoder.decode(CardRequestResponse.self, from: data)
        
        return cardRequest
    }
    
    func getCardRequests() async throws -> [CardRequestResponse] {
        let urlString: String = "\(baseURL)/api/v1/card/requests"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let requests = try jsonDecoder.decode([CardRequestResponse].self, from: data)
        
        return requests
    }
    
    func getCardRequestStatus() async throws -> CardRequestStatusResponse {
        let urlString: String = "\(baseURL)/api/v1/card/status"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let status = try jsonDecoder.decode(CardRequestStatusResponse.self, from: data)
        
        return status
    }

    func submitFeedback(
        feedbackType: String,
        rating: Int?,
        title: String,
        message: String,
        affectedArea: String?
    ) async throws -> FeedbackResponse {
        let urlString: String = "\(baseURL)/api/v1/feedback"
    func getAssignments() async throws -> [Assignment] {
        let urlString: String = "\(baseURL)/api/v1/assignments"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let requestBody = FeedbackRequest(
            feedbackType: feedbackType,
            rating: rating,
            title: title,
            message: message,
            affectedArea: affectedArea
        )

        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try jsonEncoder.encode(requestBody)
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
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        return try jsonDecoder.decode([Assignment].self, from: data)
    }

    func getAssignment(assignmentId: Int) async throws -> Assignment {
        let urlString: String = "\(baseURL)/api/v1/assignments/\(assignmentId)"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 201:
            break
        case 400, 409:
            if let errorMessage = String(data: data, encoding: .utf8) {
                throw NetworkError.serverErrorMessage(errorMessage)
            }
            throw NetworkError.serverErrorMessage("Bad request")
        case 401:
            throw NetworkError.unauthorized
        case 200:
            break
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.serverErrorMessage("Assignment not found")
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        let feedback = try jsonDecoder.decode(FeedbackResponse.self, from: data)
        return feedback
    }

    func trackTelemetryEvent(
        eventName: String,
        eventCategory: String,
        contextPayload: [String: String]?,
        screenName: String?
    ) async throws {
        let urlString: String = "\(baseURL)/api/v1/telemetry/events"
        return try jsonDecoder.decode(Assignment.self, from: data)
    }

    func submitAssignmentText(assignmentId: Int, submissionText: String) async throws -> Assignment {
        let urlString: String = "\(baseURL)/api/v1/assignments/\(assignmentId)/submit"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = AuthService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let requestBody = TelemetryEventRequest(
            eventName: eventName,
            eventCategory: eventCategory,
            contextPayload: contextPayload,
            screenName: screenName,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        )
        let requestBody = SubmitAssignmentRequest(submissionText: submissionText)

        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try jsonEncoder.encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 201:
            break
        case 400, 409:
            if let errorMessage = String(data: data, encoding: .utf8) {
                throw NetworkError.serverErrorMessage(errorMessage)
            }
            throw NetworkError.serverErrorMessage("Bad request")
        case 200:
            break
        case 400, 404, 409:
            if let errorMessage = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !errorMessage.isEmpty {
                throw NetworkError.serverErrorMessage(errorMessage)
            }
            throw NetworkError.serverErrorMessage("Could not submit assignment")
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        return try jsonDecoder.decode(Assignment.self, from: data)
    }
}
