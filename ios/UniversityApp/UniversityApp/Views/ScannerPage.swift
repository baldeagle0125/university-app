//
//  ScannerPage.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 11/02/2026.
//

import SwiftUI
import AVFoundation

struct ScannerPage: View {
    @StateObject private var viewModel = ScannerViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.session)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 250, height: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                    )
                
                Text("Align QR code or barcode within frame")
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                if viewModel.isVerifying {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                        .padding()
                } else if let result = viewModel.verificationResult {
                    VStack(spacing: 16) {
                        if result.isValid {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.green)
                            
                            Text("Valid Student ID")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text("Student: \(result.studentNumber ?? "Unknown")")
                                .font(.headline)
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.red)
                            
                            Text("Invalid Student ID")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text(result.message)
                                .font(.caption)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Scan Again") {
                            viewModel.resetScan()
                        }
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                }
                
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

#Preview {
    ScannerPage()
}
