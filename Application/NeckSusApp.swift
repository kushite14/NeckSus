import SwiftUI
import BackgroundTasks
import CloudKit

// MARK: - CloudKit Environment Key
struct CloudKitContainerKey: EnvironmentKey {
    static let defaultValue: CKContainer = .default()
}

extension EnvironmentValues {
    var cloudKitContainer: CKContainer {
        get { self[CloudKitContainerKey.self] }
        set { self[CloudKitContainerKey.self] = newValue }
    }
}

// MARK: - Main App
@main
struct NeckSusApp: App {
    @StateObject private var userSettings: UserSettings
    @StateObject private var postureManager: PostureManager
    @StateObject private var healthData = HealthDataManager()
    private let cloudKitContainer: CKContainer = .default()
    
    init() {
        let settings = UserSettings()
        _userSettings = StateObject(wrappedValue: settings)
        _postureManager = StateObject(
            wrappedValue: PostureManager(userSettings: settings)
        )
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(postureManager)
                .environmentObject(healthData)
                .environmentObject(userSettings)
                .environment(\.cloudKitContainer, cloudKitContainer)
            
            
        }
    }
    
    // MARK: - CloudKit Implementation
    private func verifyCloudKitAccess() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit Error: \(error)")
                    return
                }
                self.handleCloudKitStatus(status) // ✅ Correct: no `weak` or `?`
            }
        }
    }
    
    @MainActor
    private func handleCloudKitStatus(_ status: CKAccountStatus) {
        switch status {
        case .available: print("CloudKit: Ready")
        case .couldNotDetermine: print("CloudKit: Authorization undetermined")
        case .restricted: print("CloudKit: Restricted access")
        case .noAccount: print("CloudKit: No iCloud account")
        case .temporarilyUnavailable: print("CloudKit: Temporarily unavailable")
        @unknown default: print("CloudKit: Unknown status")
        }
    }
}
