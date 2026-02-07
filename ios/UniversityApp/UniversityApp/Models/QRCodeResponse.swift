//
//  QRCodeResponse.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 07/02/2026.
//

import Foundation

struct QRCodeResponse: Codable {
    let qrCode: String
    let expiresAt: String
}
