//
//  StudentIDPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct StudentIDPage: View {
    @StateObject private var studentViewModel = StudentViewModel()
    @StateObject private var qrViewModel = StudentIDViewModel()
    @StateObject private var cardViewModel = CardManagementViewModel()
    
    @State private var flipped = false
    @State private var showScanner = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Student ID")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Spacer()
                
                ZStack {
                    StudentIDFront(student: studentViewModel.student, hasPendingRequest: cardViewModel.hasActiveRequest)
                        .opacity(flipped ? 0 : 1)
                    
                    StudentIDBack(viewModel: qrViewModel)
                        .opacity(flipped ? 1 : 0)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                .rotation3DEffect(
                    .degrees(flipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0
                )
                .animation(.easeInOut(duration: 0.6), value: flipped)
                .onTapGesture {
                    flipped.toggle()
                }
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    showScanner = true
                } label: {
                    Text("Scan")
                        .font(.title2)
                }
                .sheet(isPresented: $showScanner) {
                    ScannerPage()
                }
                .padding()
                .glassEffect(.regular.interactive())
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Gradient(colors: backgroundColor))
        .task {
            await studentViewModel.fetchStudentProfile()
            await cardViewModel.fetchCardStatus()
        }
        .onAppear() {
            Task {
                await studentViewModel.fetchStudentProfile()
                await cardViewModel.fetchCardStatus()
            }
        }
    }
}

#Preview {
    StudentIDPage()
}
