//
//  CardManagementPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 16/02/2026.
//

import SwiftUI

struct CardManagementPage: View {
    @StateObject private var viewModel = CardManagementViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var requestType: String = "new"
    @State private var requestReason: String = ""
    @State private var showSubmitAlert: Bool = false
    
    let requestTypes = [
        ("new", "New Card"),
        ("replacement", "Replacement"),
        ("lost", "Lost Card")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        if viewModel.canSubmitNewRequest {
                            submitRequestSection
                        } else {
                            pendingRequestSection
                        }
                        
                        requestHistorySection
                    }
                    .padding()
                }
            }
            .navigationTitle("Card Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                    if let error = viewModel.errorMessage {
                        Text(error)
                    }
                }
            }
            .alert("Success", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                if let success = viewModel.successMessage {
                    Text(success)
                }
            }
            .task {
                await viewModel.fetchCardStatus()
                await viewModel.fetchCardRequests()
            }
            .background(Gradient(colors: backgroundColor))
    }
    
    private var submitRequestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Request New Card")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Request Type")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Picker("Request Type", selection: $requestType) {
                    ForEach(requestTypes, id: \.0) { type in
                        Text(type.1).tag(type.0)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Reason")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                TextField("Enter reason for request", text: $requestReason, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }
            
            Button {
                Task {
                    let success = await viewModel.submitCardRequest(requestType: requestType, requestReason: requestReason)
                    
                    if success {
                        requestReason = ""
                        requestType = "new"
                    }
                }
            } label: {
                Text("Submit Request")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(requestReason.isEmpty ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .disabled(requestReason.isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var pendingRequestSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text("Pending Request")
                .font(.headline)
            
            Text("You have a card request pending approval. You cannot submit another request until this one is processed.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var requestHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Request History")
                .font(.headline)
            
            if viewModel.cardRequests.isEmpty {
                Text("No previous requests")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.cardRequests) { request in
                    requestCard(request: request)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private func requestCard(request: CardRequestResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(request.typeDisplayName)
                    .font(.headline)
                
                Spacer()
                
                Text(request.requestStatus.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusBackgroundColor(status: request.requestStatus))
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
            
            Text(request.requestReason ?? "No reason provided")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let date = request.requestedDate {
                Text("Submitted: \(date, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let notes = request.adminNotes {
                Divider()
                
                Text("Admin Notes: \(notes)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.5))
        .cornerRadius(12)
    }
    
    private func statusBackgroundColor(status: String) -> Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "approved":
            return .green
        case "rejected":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    CardManagementPage()
}
