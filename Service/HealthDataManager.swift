//  HealthDataManager.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 13/02/2025.
//

import Foundation
import CoreData
import UIKit
import HealthKit

class HealthDataManager: NSObject, ObservableObject {
    let context = PersistenceController.shared.container.viewContext
    @Published var painLogs: [NeckSus13.PainLog] = []
    private let healthStore = HKHealthStore()
    
    public struct PainEntry: Identifiable {
        public let id = UUID()
        public let date: Date
        public let endDate: Date
        public let painLevel: Int
        public let locations: [String]
        public let radiation: [String]
        public let triggers: [String]
        public let reliefs: [String]
        public let notes: String
        public let imageFile: String            // Parameter 9
        public let duration: TimeInterval       // Parameter 10
        public let x: Double                    // Parameter 11
        public let y: Double                    // Parameter 12
        public let postureAngle: Double         // Parameter 13
        public let numbnessEntries: [NeckSus13.NumbnessEntry] // Parameter 14
        public let markedPoints: [NeckSus13.PainPoint]        // Parameter 15
        public let spineHistory: NeckSus13SpineHistory?
        public let otherMedicalHistory: OtherMedicalHistory?
    }

    func savePainEntry(_ entry: PainEntry) {
        guard let painLog = NSEntityDescription.insertNewObject(
            forEntityName: "PainLog",
            into: context
        ) as? NeckSus13.PainLog else { return }
        
        painLog.timestamp = entry.date
        painLog.endDate = entry.endDate
        painLog.painLevel = Int16(entry.painLevel)
        painLog.locations = entry.locations as NSArray
        painLog.radiation = entry.radiation as NSArray
        painLog.triggers = entry.triggers as NSArray
        painLog.reliefs = entry.reliefs as NSArray
        painLog.notes = entry.notes
        painLog.imageFile = entry.imageFile
        painLog.duration = Int16(entry.duration)
        painLog.x = entry.x
        painLog.y = entry.y
        painLog.postureAngle = entry.postureAngle
        
        entry.markedPoints.forEach { point in
            let painPoint = NeckSus13.PainPoint(context: context)
            painPoint.x = Float(point.x)
            painPoint.y = Float(point.y)
            painPoint.intensity = Int16(point.intensity)
            painPoint.notes = point.notes
            painPoint.date = point.date
            painPoint.postureAngle = point.postureAngle
            painLog.addToPainPoints(painPoint)
        }
        
        entry.numbnessEntries.forEach { entry in
            guard let numbnessEntry = NSEntityDescription.insertNewObject(
                forEntityName: "NumbnessEntry",
                into: context
            ) as? NeckSus13.NumbnessEntry else { return }
            
            numbnessEntry.frequency = entry.frequency
            numbnessEntry.laterality = entry.laterality
            numbnessEntry.site = entry.site
            painLog.addToNumbnessEntries(numbnessEntry)
        }
        
        saveContext()
    }

    func deletePainLog(at offsets: IndexSet) {
        offsets.forEach { index in
            let log = painLogs[index]
            context.delete(log)
        }
        painLogs.remove(atOffsets: offsets)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            ErrorLogger.log(error, description: "❌ Error saving CoreData context")
        }
    }

    func loadPainLogs() {
        let fetchRequest: NSFetchRequest<NeckSus13.PainLog> = NeckSus13.PainLog.fetchRequest()
        do {
            painLogs = try context.fetch(fetchRequest)
        } catch {
            ErrorLogger.log(error, description: "❌ Error loading PainLogs")
        }
    }

    func groupedPainLogs(for period: String) -> [DatedCount] {
        let fetchRequest: NSFetchRequest<NeckSus13.PainLog> = NeckSus13.PainLog.fetchRequest()
        do {
            let logs = try context.fetch(fetchRequest)
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -1, to: Date())!
            fetchRequest.predicate = NSPredicate(format: "timestamp >= %@", startDate as NSDate)
            
            let groupedLogs = Dictionary(grouping: logs) { log -> Date in
                guard let timestamp = log.timestamp else { return Date() }
                return calendar.startOfDay(for: timestamp)
            }
            
            return groupedLogs.map {
                DatedCount(date: $0.key, count: Double($0.value.count))
            }.sorted()
        } catch {
            ErrorLogger.log(error, description: "❌ Error fetching grouped PainLogs")
            return []
        }
    }

    func requestAuthorization() {
        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            HKQuantityType.quantityType(forIdentifier: .height)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if let error = error {
                ErrorLogger.log(error, description: "❌ HealthKit Authorization Error")
            }
        }
    }
}
extension HealthDataManager {
    static let preview: HealthDataManager = {
        let manager = HealthDataManager()
        let context = PersistenceController.shared.container.viewContext
        
        // Create FULL PainLog entity (mirroring savePainEntry logic)
        let painLog = PainLog(context: context)
        painLog.timestamp = Date()
        painLog.endDate = Date()
        painLog.painLevel = 3
        painLog.locations = ["Neck"] as NSArray
        painLog.radiation = ["No radiation"] as NSArray
        painLog.triggers = ["Sitting"] as NSArray
        painLog.reliefs = ["Rest"] as NSArray
        // ... set ALL other properties ...
        
        // Add mock PainPoints
        let painPoint = PainPoint(context: context)
        painPoint.x = 0.5
        painPoint.y = 0.5
        painLog.addToPainPoints(painPoint)
        
        manager.painLogs = [painLog]
        return manager
    }()
}
extension HealthDataManager {
    func getFilteredMedicalHistorySummary() -> [String] {
        return painLogs.compactMap { entry -> String? in
            var details: [String] = []
            
            // Spine History
            if let spineHistory = entry.spineHistory {
                if spineHistory.thoracicSpine { details.append("Thoracic Spine Issue") }
                if spineHistory.lumbarSpine { details.append("Lumbar Spine Issue") }
                if spineHistory.scoliosis { details.append("Scoliosis Issue") }
                if spineHistory.coccygealSpine { details.append("Coccygeal Spine Issue") }
                if spineHistory.others { details.append("Other Spine Issues") }
            }
            
            // Medical Conditions
            if let medicalHistory = entry.otherMedicalHistory {
                if medicalHistory.diabetesMellitus { details.append("Diabetes Mellitus") }
                if medicalHistory.hypertension { details.append("Hypertension") }
                if medicalHistory.hyperlipidemia { details.append("Hyperlipidemia") }
                if medicalHistory.kidneyDisease { details.append("Kidney Disease") }
                if medicalHistory.heartDisease { details.append("Heart Disease") }
            }
            
            return details.isEmpty ? nil : details.joined(separator: ", ")
        }
    }
}
