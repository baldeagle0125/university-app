//
//  FeedbackPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 17/04/2026.
//

import SwiftUI

struct FeedbackPage: View {
    @StateObject private var viewModel = FeedbackViewModel()
    @Environment(\.dismiss) private var dismiss

    private let feedbackTypes: [(String, String)] = [
        ("bug", "Bug Report"),
        ("usability", "Usability Survey"),
        ("feature", "Feature Request")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Help us improve your experience")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    typeSection
                    ratingSection
                    titleSection
                    messageSection
                    areaSection
                    submitSection
                }
                .padding()
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Gradient(colors: backgroundColor))
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.25))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Submitted", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                Text(viewModel.successMessage ?? "")
            }
            .task {
                await viewModel.trackOpen()
            }
        }
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Feedback Type")
                .font(.headline)

            Picker("Feedback Type", selection: $viewModel.feedbackType) {
                ForEach(feedbackTypes, id: \.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    @ViewBuilder
    private var ratingSection: some View {
        if viewModel.feedbackType == "usability" {
            VStack(alignment: .leading, spacing: 8) {
                Text("Usability Rating")
                    .font(.headline)

                Picker("Rating", selection: $viewModel.rating) {
                    ForEach(1...5, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.headline)

            TextField("Short summary", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details")
                .font(.headline)

            TextField("Share details about your experience", text: $viewModel.message, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(4...8)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private var areaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Affected Area (Optional)")
                .font(.headline)

            TextField("Example: card_management", text: $viewModel.affectedArea)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private var submitSection: some View {
        Button {
            Task {
                _ = await viewModel.submitFeedback()
            }
        } label: {
            Text("Submit Feedback")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canSubmit ? Color.blue : Color.gray)
                .foregroundStyle(.white)
                .cornerRadius(12)
        }
        .disabled(!viewModel.canSubmit)
    }
}

#Preview {
    FeedbackPage()
}
