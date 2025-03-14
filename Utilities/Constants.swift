//
//  Constants.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 13/02/2025.
//
import Foundation
import CoreMotion

struct Constants {
    // CoreMotion
    static let activeUpdateInterval: Double = 0.1 // 10Hz
    static let backgroundUpdateInterval: Double = 1.0 // 1Hz
    
    // Alerts
    static let alertCooldown: Double = 300 // 5 minutes
    static let postureSmoothingSamples = 10
    
    // CoreData
    static let coreDataModelName = "NeckSusData"
    
}
// MotionConstants.swift
enum MotionUnits {
    static let radiansToDegrees: Double = 180 / .pi
    static let degreesToRadians: Double = .pi / 180
}

extension CMDeviceMotion {
    var pitchDegrees: Double {
        attitude.pitch * MotionUnits.radiansToDegrees
    }
    
    var rollDegrees: Double {
        attitude.roll * MotionUnits.radiansToDegrees
    }
}
extension Notification.Name {
    static let calibrationCompleted = Notification.Name("CalibrationCompleted")
}
