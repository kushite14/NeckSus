import Foundation
import HealthKit

/// HealthBridge: Manages the secure transfer of posture data to Apple Health.
/// Strict adherence to the .mindfulSession only policy.
public actor HealthBridge {
    private let healthStore = HKHealthStore()
    private let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!

    public func requestAuthorization() async throws -> Bool {
        try await healthStore.requestAuthorization(toShare: [mindfulType], read: [mindfulType])
        return true
    }

    /// Saves a session with the required 'necksus_' metadata prefix for PhD traceability.
    public func saveSession(start: Date, end: Date, metadata: [String: Any]) async throws {
        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end,
            metadata: metadata // Ensure calling code uses necksus_ prefix
        )
        try await healthStore.save(sample)
    }
}