//
//  StudentIDBack.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 23/01/2026.
//

import SwiftUI

struct StudentIDBack: View {
    @ObservedObject var viewModel: StudentIDViewModel
    @State private var selectedCode: Int = 1
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 40)
                .frame(width: 325, height: 500)
                .opacity(0.3)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 40))
            
            VStack(alignment: .leading) {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text("Expires in \(viewModel.timeRemaining)")
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 40)
                            .frame(width: 250, height: 250)
                            .opacity(0.3)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                        } else if let codeImage = viewModel.codeImage {
                            Image(uiImage: codeImage)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 40))
                        } else if let error = viewModel.errorMessage {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                Text(error)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundColor(.red)
                        } else {
                            Text("Tap to load code")
                                .font(.caption)
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                Picker("Code Type", selection: $viewModel.currentCodeType) {
                    Text("QR-Code").tag(1)
                    Text("Barcode").tag(2)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedCode) { oldValue, newValue in
                    Task {
                        if newValue == 1 {
                            await viewModel.fetchQRCode()
                        } else {
                            await viewModel.fetchBarcode()
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .frame(width: 325, height: 500)
        }
        .task {
            await viewModel.fetchQRCode()
        }
    }
}

#Preview {
    StudentIDBack(viewModel: StudentIDViewModel())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Gradient(colors: backgroundColor))
}
