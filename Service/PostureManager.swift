import CoreMotion
import Combine

class PostureManager: ObservableObject {
    @Published var userSettings: UserSettings
    @Published var currentPitch: Double = 0.0
    @Published var currentRoll: Double = 0.0
    @Published var alertCount: Int = 0
    @Published var totalActiveTime: Int = 0 // Add missing property
    @Published var redTime: Double = 0
    @Published var yellowTime: Double = 0
    @Published var greenTime: Double = 0
    @Published var greenPercentage: Double?
    @Published var amberPercentage: Double?
    @Published var redPercentage: Double?
    private var userCalibration: CalibrationData?;
    private let motionManager = CMMotionManager()
    private let cloudKitService: CloudKitService
    private var screenTimeTimer: Timer?
    private var hourlyPostureEntries: [HourlyPostureEntry] = []
    private var hourlyTimer: Timer?
    private var alertHistory: [Date] = []
    private func checkPostureLogging() {
    }
    private func saveToJSON(entry: HourlyPostureEntry) {
        // Convert entry to JSON and save
    }
    //for HomeView pie chart
    private func updatePercentages() {
        let total = redTime + yellowTime + greenTime
        guard total > 0 else { return }
        redPercentage = (redTime / total) * 100
        amberPercentage = (yellowTime / total) * 100
        greenPercentage = (greenTime / total) * 100
    }

    
    // IN PostureManager.swift:
    func groupedPostureData(for period: String) -> [IdentifiableDateValue] {
        let calendar = Calendar.current
        let now = Date()
        
        var startDate: Date
        switch period {
        case "Day": startDate = calendar.startOfDay(for: now)
        case "Week": startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case "Month": startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        default: startDate = now
        }
        
        return hourlyPostureEntries
            .filter { $0.date >= startDate }
            .map { IdentifiableDateValue(date: $0.date, value: $0.pitch) }
    }
    func logVerifiedPosture(imageName: String, isCorrect: Bool) {
        // Track posture verification
    }

    func reviewPostureData() {
        // Fetch and present historical data
    }
    func groupedAlerts(for period: String) -> [IdentifiableDateValue] {
        let filteredAlerts = alertHistory.filter {
            Calendar.current.isDate($0, inSameDayAs: Date())
        }
        return Dictionary(grouping: filteredAlerts, by: { Calendar.current.startOfDay(for: $0) })
            .map { IdentifiableDateValue(date: $0.key, value: Double($0.value.count)) }
    }
    func updateUserSettings(_ settings: UserSettings) {
        self.userSettings = settings
        self.configureMotionTracking() // Ensure this method exists
    }
    // MARK: - RESTORED: User Settings Dependency & Initialization
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        self.cloudKitService = CloudKitService() // Initialize missing property
    }
    func saveCalibration(posture: String, pitch: Double, roll: Double) {
        // Save logic
    }
    // MARK: - RESTORED: Background Services Setup
    func startBackgroundServices() {
        configureMotionTracking()
        setupScreenTimeTracking()
        startHourlyRecording()
    }

    // MARK: - RESTORED: Motion Tracking Setup
    func configureMotionTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            ErrorLogger.log(
                NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Device motion unavailable"]),
                description: "Critical Motion Tracking Failure"
            )
            return
        }

        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            
            if let error = error {
                ErrorLogger.log(error, description: "Motion tracking error")
                return
            }
            
            self.currentPitch = motion.attitude.pitch * 180 / .pi
        }
    }

    // MARK: - RESTORED: Screen Time Tracking
    private func setupScreenTimeTracking() {
        screenTimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.totalActiveTime += 1
            self.checkAlertConditions()
            self.checkPostureLogging()
        }
    }

    // MARK: - RESTORED: Posture Alerts & Threshold Check
    private func checkAlertConditions() {
        if isPostureBeyondCalibratedThreshold() {
            triggerAlert()
        }
    }

    private func triggerAlert() {
        let now = Date()
        if let lastAlert = alertHistory.last, now.timeIntervalSince(lastAlert) < 300 {
            return
        }
        alertHistory.append(now)
        alertCount += 1
    }

    private func isPostureBeyondCalibratedThreshold() -> Bool {
        guard let calibration = userCalibration else { return false }
        let threshold: Double
        
        switch userSettings.alertSensitivity {
        case "Mild": threshold = 15
        case "Moderate": threshold = 10
        case "Strict": threshold = 5
        default: threshold = 10
        }
        
        return abs(currentPitch - calibration.pitch) > threshold
    }

    // MARK: - RESTORED: Hourly Posture Data Logging
    private func startHourlyRecording() {
        hourlyTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let entry = HourlyPostureEntry(date: Date(), pitch: self.currentPitch, roll: self.currentRoll)
            self.saveToJSON(entry: entry)
        }
    }
}
struct HourlyPostureEntry: Codable { // ✅ Add this
    let date: Date
    let pitch: Double
    let roll: Double
}
