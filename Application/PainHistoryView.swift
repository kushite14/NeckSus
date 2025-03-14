//
//  PainHistoryView.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 11/03/2025.
//

import SwiftUI

struct PainHistoryView: View {
    @EnvironmentObject var healthData: HealthDataManager
    
    private var sortedPainEntries: [HealthDataManager.PainEntry] {
        healthData.painLogs.compactMap { log -> HealthDataManager.PainEntry? in
            guard let timestamp = log.timestamp else { return nil }
            return HealthDataManager.PainEntry(
                date: timestamp,
                endDate: log.endDate ?? Date(),
                painLevel: Int(log.painLevel),
                locations: log.locations as? [String] ?? [],
                radiation: log.radiation as? [String] ?? [],
                triggers: log.triggers as? [String] ?? [],
                reliefs: log.reliefs as? [String] ?? [],
                notes: log.notes ?? "",
                imageFile: log.imageFile ?? "",
                duration: Double(log.duration),
                x: log.x,
                y: log.y,
                postureAngle: log.postureAngle,
                numbnessEntries: (log.numbnessEntries?.allObjects as? [NeckSus13.NumbnessEntry]) ?? [],
                markedPoints: (log.painPoints?.allObjects as? [NeckSus13.PainPoint]) ?? [],
                spineHistory: log.spineHistory,
                otherMedicalHistory: log.otherMedicalHistory
            )
        }.sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        List {
            // Latest Entry Section
            if let latestEntry = sortedPainEntries.first {
                Section(header: Text("Latest Entry")) {
                    PainEntryRow(entry: latestEntry)
                }
            }
            
            // All Entries
            ForEach(sortedPainEntries) { entry in
                Section(header: Text(entry.date, formatter: DateFormats.analytics)) {
                    VStack(alignment: .leading) {
                        Text("\(entry.painLevel)/10 Pain Level")
                            .font(.headline)
                        
                        if !entry.locations.isEmpty {
                            Text("Location: \(entry.locations.joined(separator: ", "))")
                        }
                        
                        let historyDetails = getFilteredMedicalHistoryDetails(entry: entry)
                        if !historyDetails.isEmpty {
                            Text("Medical History: \(historyDetails)")
                                .font(.caption)
                        }
                        
                        if !entry.notes.isEmpty {
                            Text(entry.notes)
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Pain History")
    }
    
    // Nested View for Latest Entry Row
    // Inside PainHistoryView.swift
    private struct PainEntryRow: View {
        let entry: HealthDataManager.PainEntry
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(entry.painLevel)/10 Pain Level")
                    .font(.headline)
                
                // Directly check if the string is empty
                let historyDetails = getFilteredMedicalHistoryDetails(entry: entry)
                if !historyDetails.isEmpty {
                    Text(historyDetails)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(entry.date, formatter: DateFormats.analytics)
                    .font(.caption)
            }
        }
        
        private func getFilteredMedicalHistoryDetails(entry: HealthDataManager.PainEntry) -> String {
            var details: [String] = []
            
            // Spine History
            if let spine = entry.spineHistory {
                if spine.thoracicSpine { details.append("Thoracic Spine Issue") }
                if spine.lumbarSpine { details.append("Lumbar Spine Issue") }
                if spine.scoliosis { details.append("Scoliosis Issue") }
                if spine.coccygealSpine { details.append("Coccygeal Spine Issue") }
                if spine.others { details.append("Other Spine Issues") }
            }
            
            // Medical Conditions
            if let medical = entry.otherMedicalHistory {
                if medical.diabetesMellitus { details.append("Diabetes Mellitus") }
                if medical.hypertension { details.append("Hypertension") }
                if medical.hyperlipidemia { details.append("Hyperlipidemia") }
                if medical.kidneyDisease { details.append("Kidney Disease") }
                if medical.heartDisease { details.append("Heart Disease") }
            }
            
            return details.joined(separator: ", ")
        }
    }
    
    // Original Medical History Filter (Retained for other sections)
    private func getFilteredMedicalHistoryDetails(entry: HealthDataManager.PainEntry) -> String {
        var details: [String] = []
        
        if let spine = entry.spineHistory {
            if spine.thoracicSpine { details.append("Thoracic Spine Issue") }
            if spine.lumbarSpine { details.append("Lumbar Spine Issue") }
            if spine.scoliosis { details.append("Scoliosis Issue") }
            if spine.coccygealSpine { details.append("Coccygeal Spine Issue") }
            if spine.others { details.append("Other Spine Issues") }
        }
        
        if let medical = entry.otherMedicalHistory {
            if medical.diabetesMellitus { details.append("Diabetes Mellitus") }
            if medical.hypertension { details.append("Hypertension") }
            if medical.hyperlipidemia { details.append("Hyperlipidemia") }
            if medical.kidneyDisease { details.append("Kidney Disease") }
            if medical.heartDisease { details.append("Heart Disease") }
        }
        
        return details.isEmpty ? "" : details.joined(separator: ", ")
    }
}
