import CloudKit

class CloudKitService {
    private let container = CKContainer.default()
    private var lastSyncTime: Date = Date.distantPast

    func savePostureRecord(pitch: Double, roll: Double) async throws {
        let now = Date()
        guard now.timeIntervalSince(lastSyncTime) > 60 else {
            let error = CKError(.requestRateLimited)
            ErrorLogger.log(error, description: "CloudKit sync throttled")
            throw error
     
        }
        
        lastSyncTime = now
        let record = CKRecord(recordType: "PostureData")
        record["pitch"] = pitch
        record["roll"] = roll
        record["timestamp"] = now

        do {
               try await container.publicCloudDatabase.save(record)
           } catch {
               ErrorLogger.log(error, description: "CloudKit save failed")
               throw error
           }
       }
}
