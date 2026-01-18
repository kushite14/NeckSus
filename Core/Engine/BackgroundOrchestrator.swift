import Foundation
import BackgroundTasks

/// BackgroundOrchestrator: Manages battery-efficient automation.
/// Handles 5-minute batch persistence and nightly rollup generation.
public struct BackgroundOrchestrator {
    public static let batchTaskID = "com.necksus.batchWrite"
    public static let cleanupTaskID = "com.necksus.nightlyCleanup"

    /// Schedules the next batch write. 
    /// Requirement: Battery impact < 2% via system-managed execution.
    public func scheduleBatchWrite() {
        let request = BGProcessingTaskRequest(identifier: Self.batchTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // 5 mins
        request.requiresExternalPower = false
        
        try? BGTaskScheduler.shared.submit(request)
    }
}