//  ErrorLogger.swift
//  NeckSus13
//  Created by Khalid Mukhtar on 13/02/2025.

import Foundation
import CoreData
import CloudKit

class ErrorLogger {
    // Singleton instance for calling instance methods if needed
    static let shared = ErrorLogger()

    // Static log function – call on the type
    static func log(_ error: Error, description: String) {
        let message = "\(Date()): \(description) - \(error.localizedDescription)"
        print(message)
        // TODO: Add file logging here if needed
    }

    // Instance helper methods can use the static log
    func logCoreDataError(_ error: Error, context: NSManagedObjectContext) {
        // Call static log with description, then handle rollback
        ErrorLogger.log(error, description: "CoreData Error")
        context.rollback()
    }

    func logCloudKitError(_ error: CKError) {
        // Call static log with error code included in description
        ErrorLogger.log(error, description: "CloudKit Error (Code \(error.errorCode))")
    }
}

