//
//  ProfilePage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct ProfilePage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var studentViewModel = StudentViewModel()
    
    @State private var showLogoutAlert: Bool = false
    @State private var showCardManagement: Bool = false
    @State private var showFeedback: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                profileHeader
                personalInfoSection
                membershipsSection
                actionsSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(Gradient(colors: backgroundColor))
        .overlay {
            if studentViewModel.isLoading {
                ProgressView("Loading profile...")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .refreshable {
            await studentViewModel.fetchStudentProfile()
        }
        .task {
            await studentViewModel.fetchStudentProfile()
        }
        .alert("Logout?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            Button("Logout", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Profile Error", isPresented: .constant(studentViewModel.errorMessage != nil)) {
            Button("OK") {
                studentViewModel.errorMessage = nil
            }
        } message: {
            Text(studentViewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showCardManagement) {
            CardManagementPage()
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackPage()
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            profileAvatar

            VStack(alignment: .leading, spacing: 6) {
                Text(studentViewModel.student?.fullName ?? "Student Name")
                    .font(.title2)
                    .fontWeight(.bold)
                    .redacted(reason: studentViewModel.student == nil ? .placeholder : [])

                Text(studentViewModel.student?.studentNumber ?? "SETU000000")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .redacted(reason: studentViewModel.student == nil ? .placeholder : [])

                Text(studentViewModel.student?.email ?? "student@university.ie")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .redacted(reason: studentViewModel.student == nil ? .placeholder : [])
            }

            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
    }

    private var profileAvatar: some View {
        Group {
            if let photoURL = studentViewModel.student?.profilePhotoUrlObject {
                AsyncImage(url: photoURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .padding(8)
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray)
                    .padding(8)
            }
        }
        .frame(width: 84, height: 84)
        .background(.white.opacity(0.45), in: Circle())
        .clipShape(Circle())
    }

    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Information")
                .font(.headline)

            infoRow(label: "Course", value: courseValue)
            infoRow(label: "Date of Birth", value: birthDateValue)
            infoRow(label: "SU Position", value: suPositionValue)
            infoRow(label: "Program Code", value: studentViewModel.student?.programCode ?? "Not available")
            infoRow(label: "Card Status", value: studentViewModel.student?.cardStatus.capitalized ?? "Unknown")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
    }

    private var membershipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memberships")
                .font(.headline)

            if memberships.isEmpty {
                Text("No memberships available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(memberships, id: \.self) { membership in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text(membership)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                showCardManagement = true
            } label: {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.title2)

                    VStack(alignment: .leading) {
                        Text("Card Management")
                            .font(.headline)

                        Text("Request or replace your student card")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            .foregroundStyle(.primary)
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))

            Button {
                showFeedback = true
            } label: {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.title2)

                    VStack(alignment: .leading) {
                        Text("Send Feedback")
                            .font(.headline)

                        Text("Report bugs, usability issues, or feature ideas")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            .foregroundStyle(.primary)
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))

            Button {
                showLogoutAlert = true
            } label: {
                Text("Logout")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .glassEffect(.regular.interactive())
            .foregroundStyle(.red)
        }
    }

    private var courseValue: String {
        studentViewModel.student?.courseTitle ?? "Not available"
    }

    private var suPositionValue: String {
        studentViewModel.student?.suPosition ?? "Not available"
    }

    private var birthDateValue: String {
        guard let date = studentViewModel.student?.dateOfBirthObject else {
            return "Not available"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }

    private var memberships: [String] {
        studentViewModel.student?.memberships ?? []
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)

            Text(value)
                .font(.subheadline)

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    ProfilePage()
        .environmentObject(AuthViewModel())
}
