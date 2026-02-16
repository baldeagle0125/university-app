//
//  CardManagementViewModel.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 16/02/2026.
//

import Foundation
import Combine

@MainActor
class CardManagementViewModel: ObservableObject {
    @Published var cardRequests: [CardRequestResponse] = []
    @Published var hasActiveRequest: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let networkService = NetworkService.shared
    
    func fetchCardRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            cardRequests = try await networkService.getCardRequests()
            
            updateActiveRequestStatus()
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load card requests"
        }
        
        isLoading = false
    }
    
    func fetchCardStatus() async {
        do {
            let status = try await networkService.getCardRequestStatus()
            hasActiveRequest = status.hasRequest
        } catch {
            hasActiveRequest = false
        }
    }
    
    func submitCardRequest(requestType: String, requestReason: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let newRequest = try await networkService.createCardRequest(requestType: requestType, requestReason: requestReason)
            
            cardRequests.insert(newRequest, at: 0)
            hasActiveRequest = true
            
            successMessage = "Card request submitted successfully"
            isLoading = false
            return true
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Failed to submit card request"
            isLoading = false
            return false
        }
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    private func updateActiveRequestStatus() {
        hasActiveRequest = cardRequests.contains {
            $0.requestStatus == "pending"
        }
    }
    
    var pendingRequest: CardRequestResponse? {
        cardRequests.first {
            $0.requestStatus == "pending"
        }
    }
    
    var canSubmitNewRequest: Bool {
        !hasActiveRequest
    }
}
