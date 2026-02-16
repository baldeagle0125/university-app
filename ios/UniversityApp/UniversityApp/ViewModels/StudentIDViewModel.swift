//
//  StudentIDViewModel.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 07/02/2026.
//

import Foundation
import Combine
import SwiftUI

class StudentIDViewModel: ObservableObject {
    @Published var codeImage: UIImage?
    @Published var expiresAt: Date?
    @Published var currentCodeType: Int = 1
    @Published var timeRemaining: String = "2:00"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var timer: Timer?
    
    func fetchQRCode() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await NetworkService.shared.fetchQRCode()
            
            if let imageData = Data(base64Encoded: response.code),
               let image = UIImage(data: imageData) {
                await MainActor.run {
                    self.codeImage = image
                }
            }
            
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: response.expiresAt) {
                await MainActor.run {
                    self.expiresAt = date
                    self.startCountdown()
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func fetchBarcode() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await NetworkService.shared.fetchBarcode()
            
            if let imageData = Data(base64Encoded: response.code),
               let image = UIImage(data: imageData) {
                await MainActor.run {
                    self.codeImage = image
                }
            }
            
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: response.expiresAt) {
                await MainActor.run {
                    self.expiresAt = date
                    self.startCountdown()
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func startCountdown() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        guard let expiresAt = expiresAt else {
            return
        }
        
        let now = Date()
        let timeInterval = expiresAt.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            timer?.invalidate()
            timeRemaining = "0:00"
            Task {
                if currentCodeType == 1 {
                    await fetchQRCode()
                } else {
                    await fetchBarcode()
                }
            }
        } else {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            timeRemaining = String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
