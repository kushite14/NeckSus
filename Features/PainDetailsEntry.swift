import SwiftUI
import Foundation

struct PainDataModel {
    var painLevel: Int = 0
    var locations: [String] = []
    var radiation: [String] = []
    var triggers: [String] = []
    var reliefMethods: [String] = []
    var spineHistory: [String] = []
    var medicalHistory: [String] = []
    var startDate: Date = Date()
    var endDate: Date = Date()
    var notes: String = ""
}

struct PainEntryDetails: View {
    @EnvironmentObject var healthData: HealthDataManager
    @Environment(\.dismiss) var dismiss
    @State private var painData = PainDataModel()
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private var duration: String {
        let formatter = DateIntervalFormatter()
        return formatter.string(from: painData.startDate, to: painData.endDate)
    }

    private var durationColor: Color {
        let days = Calendar.current.dateComponents([.day], from: painData.startDate, to: painData.endDate).day ?? 0
        return days > 7 ? .red : days > 3 ? .orange : .green
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Symptom Tracker")
                            .font(.title2.bold())
                            .foregroundColor(.blue)
                        
                        Text("**Timely tracking** helps identify patterns. Capture _symptom duration_ to monitor:")
                            .font(.subheadline)
                        
                        BulletPoint(text: "Improvement trends (shortening duration)")
                        BulletPoint(text: "Worsening conditions (prolonged episodes)")
                        BulletPoint(text: "Treatment effectiveness")
                    }
                    .padding(.vertical)
                }

                Section(header: Text("Pain Level")) {
                    PainLevelPicker(painLevel: $painData.painLevel)
                }
                
                Section(header: Text("Pain Location")) {
                    MultiSelectPicker(
                        title: "Select Locations",
                        options: ["Neck", "Back", "Shoulders"],
                        selection: $painData.locations
                    )
                }
                
                Section(header: Text("Radiation")) {
                    MultiSelectPicker(
                        title: "Radiating To",
                        options: ["Arm", "Leg", "Back"],
                        selection: $painData.radiation
                    )
                }
                
                Section(header: Text("Triggers")) {
                    MultiSelectPicker(
                        title: "What worsens pain?",
                        options: ["Sitting", "Standing", "Bending"],
                        selection: $painData.triggers
                    )
                }
                
                Section(header: Text("Relief Methods")) {
                    MultiSelectPicker(
                        title: "What helps?",
                        options: ["Rest", "Medication", "Massage"],
                        selection: $painData.reliefMethods
                    )
                }
                Section(header: Text("Spine History")) {
                    MultiSelectPicker(
                        title: "Spine Issues",
                        options: ["Thoracic", "Lumbar", "Scoliosis", "Coccygeal", "Other"],
                        selection: $painData.spineHistory
                    )
                }

                Section(header: Text("Medical History")) {
                    MultiSelectPicker(
                        title: "Conditions",
                        options: ["Diabetes", "Hypertension", "Kidney Disease", "Heart Disease"],
                        selection: $painData.medicalHistory
                    )
                }
                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $painData.notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Save Entry") { savePainEntry() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Pain Entry Details")
        }
    }

    func savePainEntry() {
        let newEntry = HealthDataManager.PainEntry(
            date: painData.startDate,
            endDate: painData.endDate,
            painLevel: painData.painLevel,
            locations: painData.locations,
            radiation: painData.radiation,
            triggers: painData.triggers,
            reliefs: painData.reliefMethods,
            notes: painData.notes,
            imageFile: "PainMarking",
            duration: 0.0,
            x: 0.0,
            y: 0.0,
            postureAngle: 0.0,
            numbnessEntries: [],
            markedPoints: [],
            spineHistory: nil, // Add missing parameter (or pass actual data)
            otherMedicalHistory: nil        )
        healthData.savePainEntry(newEntry)
        dismiss()
    }
}

struct BulletPoint: View {
    let text: String
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}
