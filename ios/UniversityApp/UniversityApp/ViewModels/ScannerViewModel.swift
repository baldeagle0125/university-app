//
//  ScannerViewModel.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 11/02/2026.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

class ScannerViewModel: NSObject, ObservableObject {
    @Published var verificationResult: VerifyResponse?
    @Published var isVerifying = false
    
    let session = AVCaptureSession()
    private var isScanning = true
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get camera device")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to initialize video input: \(error)")
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            print("Failed to add video input to session")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.metadataObjectTypes = [.qr, .code128]
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        } else {
            print("Failed to add metadata output to session")
            return
        }
    }
    
    func startScanning() {
        isScanning = true
        verificationResult = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopScanning() {
        isScanning = false
        session.stopRunning()
    }
    
    func resetScan() {
        verificationResult = nil
        isScanning = true
    }
    
    private func handleScannedCode(code: String) {
        guard isScanning else {
            return
        }
        
        isScanning = false
        isVerifying = false
        
        Task {
            do {
                let result = try await NetworkService.shared.verifyCode(token: code)
                await MainActor.run {
                    self.verificationResult = result
                    self.isVerifying = false
                }
            } catch {
                await MainActor.run {
                    self.verificationResult = VerifyResponse(isValid: false, studentNumber: nil, message: error.localizedDescription)
                    self.isVerifying = false
                }
            }
        }
    }
}

extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        handleScannedCode(code: stringValue)
    }
}
