//
//  AssignmentCard.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 17/04/2026.
//

import SwiftUI

struct AssignmentCard: View {
    let assignment: Assignment
    let onSubmitTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.title)
                        .font(.headline)

                    if let dueDate = assignment.dueDateObject {
                        Text("Deadline: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(assignment.statusDisplayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusBackgroundColor)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }

            if let description = assignment.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(assignment.reminderText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(reminderColor)

            if !assignment.isSubmitted {
                Button {
                    onSubmitTap?()
                } label: {
                    Text("Submit")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private var reminderColor: Color {
        if assignment.isSubmitted {
            return .green
        }

        if assignment.isOverdue {
            return .red
        }

        if assignment.isDueSoon {
            return .orange
        }

        return .secondary
    }

    private var statusBackgroundColor: Color {
        switch assignment.status.lowercased() {
        case "submitted":
            return .green
        case "overdue":
            return .red
        case "assigned":
            return .blue
        default:
            return .gray
        }
    }
}

#Preview {
    AssignmentCard(
        assignment: Assignment(
            id: 1,
            studentNumber: "SETU000001",
            title: "Database Design Report",
            description: "Submit normalization analysis.",
            dueDate: "2026-04-30T15:00:00Z",
            status: "assigned",
            daysUntilDue: 3,
            isOverdue: false,
            submissionText: nil,
            submittedAt: nil,
            createdAt: "2026-04-01T11:00:00Z",
            updatedAt: "2026-04-01T11:00:00Z"
        ),
        onSubmitTap: {}
    )
    .padding()
}
