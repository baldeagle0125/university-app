//
//  Service.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 16/02/2026.
//

import Foundation

struct Service: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let isAvailable: Bool
}
