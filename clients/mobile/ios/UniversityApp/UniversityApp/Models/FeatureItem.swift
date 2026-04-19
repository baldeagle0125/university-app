//
//  FeatureItem.swift
//  UniversityApp
//
//  Created by Ihor Melashchenko on 16/02/2026.
//

import Foundation
import SwiftUI

struct FeatureItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let gradient: [Color]
}
