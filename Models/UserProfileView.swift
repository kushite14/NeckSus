import SwiftUI

class UserSettings: ObservableObject {
    @EnvironmentObject var userSettings: UserSettings
    @Published var alertSensitivity: String = "Moderate" // Mild/Moderate/Strict
    @Published var backgroundTrackingEnabled: Bool = true
    @Published var age: Int {
        didSet { UserDefaults.standard.set(age, forKey: "userAge") }
    }
    @Published var gender: String {
        didSet { UserDefaults.standard.set(gender, forKey: "userGender") }
    }
    @Published var workHours: Int {
        didSet { UserDefaults.standard.set(workHours, forKey: "userWorkHours") }
    }
    @Published var occupation: String {
        didSet { UserDefaults.standard.set(occupation, forKey: "userOccupation") }
    }
    @Published var cervicalHistory: Bool {
        didSet { UserDefaults.standard.set(cervicalHistory, forKey: "userCervicalHistory") }
    }
    @Published var severity: String {
        didSet { UserDefaults.standard.set(severity, forKey: "userSeverity") }
    }
    @Published var dexterity: String {
        didSet { UserDefaults.standard.set(dexterity, forKey: "userDexterity") }
    }

    init() {
        self.age = UserDefaults.standard.integer(forKey: "userAge") == 0 ? 35 : UserDefaults.standard.integer(forKey: "userAge")
        self.gender = UserDefaults.standard.string(forKey: "userGender") ?? "Female"
        self.workHours = UserDefaults.standard.integer(forKey: "userWorkHours")
        self.occupation = UserDefaults.standard.string(forKey: "userOccupation") ?? "Office"
        self.cervicalHistory = UserDefaults.standard.bool(forKey: "userCervicalHistory")
        self.severity = UserDefaults.standard.string(forKey: "userSeverity") ?? "Mild"
        self.dexterity = UserDefaults.standard.string(forKey: "userDexterity") ?? "Right"
    }
}

struct UserProfileView: View {
    @StateObject var userSettings = UserSettings() // ✅ Now manages user settings & UI
    
    var body: some View {
        NavigationStack {
            Form {
                // Demographics Section
                Section(header: Text("Demographics")) {
                    Stepper("Age: \(userSettings.age)",
                            value: $userSettings.age,
                            in: 30...100) // ✅ Age validation
                    Picker("Gender", selection: $userSettings.gender) {
                        Text("Female").tag("Female")
                        Text("Male").tag("Male")
                    }
                    Picker("Dexterity", selection: $userSettings.dexterity) {
                        Text("Left").tag("Left")
                        Text("Right").tag("Right")
                        Text("Ambidextrous").tag("Ambidextrous")
                    }
                }
                
                // Occupation Section
                Section(header: Text("Occupation")) {
                    Picker("Job Type", selection: $userSettings.occupation) {
                        Text("Health Care").tag("Health Care")
                        Text("Field officer").tag("Field officer")
                        Text("Pro. Athlete").tag("Pro. Athlete")
                        Text("Office").tag("Office")
                        Text("Manual Labor").tag("Manual Labor")
                        Text("Student").tag("Student")
                        Text("Housewife").tag("Housewife")
                        Text("Other").tag("Other")
                    }
                    Stepper("Work Hours: \(userSettings.workHours)",
                            value: $userSettings.workHours,
                            in: 40...96) // ✅ Expanded range for accuracy
                }
                
                // Medical History Section
                Section(header: Text("Medical History")) {
                    Toggle("Cervical Spine History",
                           isOn: $userSettings.cervicalHistory)
                    
                    if userSettings.cervicalHistory {
                        Picker("Severity", selection: $userSettings.severity) {
                            Text("Mild").tag("Mild")
                            Text("Moderate").tag("Moderate")
                            Text("Severe").tag("Severe")
                        }
                    }
                }
                
                // App Preferences
                Section(header: Text("Preferences")) {
                    Toggle("Enable Background Tracking",
                           isOn: $userSettings.backgroundTrackingEnabled)
                    
                    Picker("Alert Sensitivity", selection: $userSettings.alertSensitivity) {
                        Text("Mild").tag("Mild")
                        Text("Moderate").tag("Moderate")
                        Text("Strict").tag("Strict")
                    }
                }
            }
            .navigationTitle("Profile & Settings")
        }
    }
}
