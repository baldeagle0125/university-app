//
//  StudentViewModel.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 09/02/2026.
//

import Foundation
import Combine

class StudentViewModel: ObservableObject {
    @Published var student: Student?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchStudentProfile() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        print("Fetching profile...")
        
        do {
            let student = try await NetworkService.shared.fetchProfile()
            
            print("Profile loaded: \(student.firstName)")
            
            await MainActor.run {
                self.student = student
                self.isLoading = false
            }
        } catch {
            print("Profile error: \(error)")
            
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
