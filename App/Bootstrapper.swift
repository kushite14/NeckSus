import Foundation
import SwiftUI

/// Bootstrapper: The dependency injection root for NeckSus 14.
/// Initializes all Swift 6 Actors and provides them to the UI.
@MainActor
public final class Bootstrapper: ObservableObject {
    public let engine: PostureEngine
    public let health: HealthBridge
    public let logger: AuditLogger
    public let recall: DataRecallActor
    
    public init() {
        self.engine = PostureEngine()
        self.health = HealthBridge()
        self.logger = AuditLogger()
        self.recall = DataRecallActor()
        
        logger.log(event: "System_Bootstrapped", metadata: ["version": "14.0"])
    }
}