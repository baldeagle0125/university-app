//
//  AssignmentTrackerPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 17/04/2026.
//

import SwiftUI

struct AssignmentTrackerPage: View {
    @StateObject private var viewModel = AssignmentTrackerViewModel()

    @State private var selectedAssignment: Assignment?
    @State private var submissionText: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.assignments.isEmpty && !viewModel.isLoading {
                        emptyState
                    }

                    section(title: "Overdue", assignments: viewModel.overdueAssignments)
                    section(title: "Due Soon", assignments: viewModel.dueSoonAssignments)
                    section(title: "Upcoming", assignments: viewModel.upcomingAssignments)
                    section(title: "Submitted", assignments: viewModel.submittedAssignments)
                }
                .padding(20)
            }
            .navigationTitle("Assignments")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.clearMessages() } }
            )) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Success", isPresented: Binding(
                get: { viewModel.successMessage != nil },
                set: { if !$0 { viewModel.clearMessages() } }
            )) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                Text(viewModel.successMessage ?? "")
            }
            .sheet(item: $selectedAssignment) { assignment in
                submissionSheet(assignment: assignment)
            }
            .task {
                await viewModel.fetchAssignments()
            }
            .refreshable {
                await viewModel.fetchAssignments()
            }
            .background(Gradient(colors: backgroundColor))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No assignments yet")
                .font(.headline)

            Text("Your upcoming coursework and deadlines will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    @ViewBuilder
    private func section(title: String, assignments: [Assignment]) -> some View {
        if !assignments.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)

                ForEach(assignments) { assignment in
                    AssignmentCard(assignment: assignment) {
                        selectedAssignment = assignment
                    }
                }
            }
        }
    }

    private func submissionSheet(assignment: Assignment) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(assignment.title)
                    .font(.headline)

                if let dueDate = assignment.dueDateObject {
                    Text("Deadline: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let description = assignment.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("Submission")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                TextEditor(text: $submissionText)
                    .frame(minHeight: 140)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                Button {
                    Task {
                        let success = await viewModel.submitAssignment(
                            assignmentID: assignment.id,
                            submissionText: submissionText
                        )

                        if success {
                            submissionText = ""
                            selectedAssignment = nil
                        }
                    }
                } label: {
                    Text("Submit Assignment")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(submissionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(submissionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("Submit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        selectedAssignment = nil
                        submissionText = ""
                    }
                }
            }
        }
    }
}

#Preview {
    AssignmentTrackerPage()
}
