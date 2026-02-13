//
//  VerifyResponse.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 11/02/2026.
//

import Foundation

struct VerifyResponse: Codable {
    let isValid: Bool
    let studentNumber: String?
    let message: String
}
