//
//  Models.swift
//  NeckSus13
//

import Foundation

// ✅ Single source for date-value structures
struct DatedValue: Identifiable, Comparable {
    let date: Date
    let value: Double
    var id: Date { date }
    
    static func < (lhs: DatedValue, rhs: DatedValue) -> Bool {
        lhs.date < rhs.date
    }
}

struct DatedCount: Identifiable, Comparable {
    let date: Date
    let count: Double
    var id: Date { date }

    static func < (lhs: DatedCount, rhs: DatedCount) -> Bool {
        lhs.date < rhs.date
    }
}

// ✅ Now merged from IdentifiableDateValue.swift
struct IdentifiableDateValue: Identifiable, Comparable {
    let id = UUID()
    let date: Date
    let value: Double
    
    static func < (lhs: IdentifiableDateValue, rhs: IdentifiableDateValue) -> Bool {
        lhs.date < rhs.date
    }
}
