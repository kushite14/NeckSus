//
//  DateUtils.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 09/03/2025.
//
// DateUtils.swift
import SwiftUI

enum DateFormats {
    static let analytics: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
    static let backup: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
