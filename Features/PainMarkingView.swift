import SwiftUI
import CoreData

struct MarkedPoint: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    var intensity: Int
    var notes: String
    let date: Date
    let postureAngle: Double
}

struct PainMarkingView: View {
    @EnvironmentObject var postureManager: PostureManager
    @EnvironmentObject var healthData: HealthDataManager
    @Environment(\.managedObjectContext) private var context // ✅ Inject Core Data Context
    @Environment(\.dismiss) var dismiss
    
    @Binding var navigationPath: NavigationPath
    
    // ✅ Properties
    @State private var markedPoints: [MarkedPoint] = []
    @State private var symptomStartDate = Date()
    @State private var showDatePicker = false
    @State private var painLevel: Int = 0
    @State private var thoracicSpine = false
    @State private var lumbarSpine = false
    @State private var scoliosis = false
    @State private var coccygealSpine = false
    @State private var others = false
    @State private var locations: [String] = []
    @State private var radiation: [String] = []
    @State private var triggers: [String] = []
    @State private var reliefs: [String] = []
    @State private var notes: String = ""
    @State private var imageFile: String = "default_image.png"
    @State private var duration: TimeInterval = 0
    @State private var xCoordinate: Double = 0
    @State private var yCoordinate: Double = 0
    @State private var postureAngle: Double = 0
    @State private var numbnessEntries: [NeckSus13.NumbnessEntry] = []
    @State private var imageScale = CGSize(width: 1.0, height: 1.0) // ✅ Ensure Initialization
    @State private var offset = CGSize(width: 0, height: 0) // ✅ Ensure Initialization
    let coreDataManager = PersistenceController.shared
    var body: some View {
        VStack {
            // ✅ Header Section
            Text("Mark Pain Locations")
                .font(.title2.bold())
                .padding(.bottom)

            // ✅ Date Selection
            HStack {
                Image(systemName: "calendar")
                Text("Symptom Start: \(symptomStartDate.formatted(date: .abbreviated, time: .omitted))")
                Spacer()
                Button("Change") { showDatePicker.toggle() }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)

            // ✅ Pain Marking Canvas (Optimized)
            GeometryReader { geometry in
                Image("PainMarking")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .contentShape(Rectangle())
                    .gesture(tapGesture)
                    .overlay {
                        ForEach(markedPoints) { point in
                            painMarker(for: point) // ✅ Extracted Function
                        }
                    }
            }
            .frame(height: UIScreen.main.bounds.height * 0.7)

            // ✅ Control Buttons
            HStack {
                Button("Undo") {
                    if !markedPoints.isEmpty {
                        markedPoints.removeLast()
                        navigationPath.removeLast()
                    }
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(markedPoints.isEmpty)

                Spacer()

                Button("Save") {
                    saveMarkedPoints()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
            .padding()
        }
        .navigationTitle("Pain Marking")
        .sheet(isPresented: $showDatePicker) {
            DatePicker("Symptom Start Date", selection: $symptomStartDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
        }
    }

    // ✅ Tap Gesture to Mark Pain Points
    private var tapGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onEnded { value in
                let newPoint = MarkedPoint(
                    x: value.location.x,
                    y: value.location.y,
                    intensity: 5,
                    notes: "",
                    date: Date(),
                    postureAngle: postureManager.currentPitch
                )
                markedPoints.append(newPoint)
            }
    }

    // ✅ Extract Position Calculation
    private func computedPosition(for point: MarkedPoint) -> CGPoint {
        let xPos = (point.x / imageScale.width) + offset.width
        let yPos = (point.y / imageScale.height) + offset.height
        return CGPoint(x: xPos, y: yPos)
    }

    // ✅ Extracted Circle View for Pain Marker
    @ViewBuilder
    private func painMarker(for point: MarkedPoint) -> some View {
        Circle()
            .fill(Color.red.opacity(0.7))
            .frame(width: 24, height: 24)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .position(computedPosition(for: point))
    }

    // ✅ Save Marked Points to Core Data
    private func saveMarkedPoints() {
        let newEntry = HealthDataManager.PainEntry(
            date: Date(),
            endDate: Date(),
            painLevel: painLevel,
            locations: locations,
            radiation: radiation,
            triggers: triggers,
            reliefs: reliefs,
            notes: notes,
            imageFile: imageFile,
            duration: duration,
            x: xCoordinate,
            y: yCoordinate,
            postureAngle: postureAngle,
            numbnessEntries: numbnessEntries,
            markedPoints: markedPoints.map { point in
                let coreDataPoint = NeckSus13.PainPoint(context: context)
                coreDataPoint.x = Float(point.x)
                coreDataPoint.y = Float(point.y)
                coreDataPoint.intensity = Int16(point.intensity)
                coreDataPoint.notes = point.notes
                coreDataPoint.date = point.date
                coreDataPoint.postureAngle = point.postureAngle
                return coreDataPoint
            },
            spineHistory: nil,      // 🔥 Add this line
            otherMedicalHistory: nil //
        )
        healthData.savePainEntry(newEntry) // ✅ Correct function name

    }
}
