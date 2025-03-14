import SwiftUI
import UIKit

// Move extension outside the struct
private extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}

struct CalibrationView: View {
    @EnvironmentObject var postureManager: PostureManager
    @Environment(\.presentationMode) var presentationMode
    @State private var calibrationStep = 0
    @State private var countdown = 10
    @State private var timer: Timer?
    @State private var calibrationValues: [Double] = []
    @State private var isCalibrating = false
    @State private var calibrationCompleted = false
    @State private var showAveragePitch = false
    
    let calibrationPostures = [
        ("SittingFreeHand", "Free Hand"),
        ("SittingElbowSupport", "Sitting with Elbow support"),
        ("StandElbowSupport", "Standing with Elbow support")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(calibrationPostures[calibrationStep].0)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                Text(calibrationPostures[calibrationStep].1)
                    .font(.title2)
                    .foregroundColor(colorForStep(calibrationStep))
                
                if isCalibrating {
                    Text("Hold this position for \(countdown) seconds")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                if showAveragePitch && !calibrationValues.isEmpty {
                    Text("Average Pitch: \(String(format: "%.1f°", calibrationValues.average))")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                if calibrationCompleted {
                    Text("Calibration Completed Successfully!")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                }
                
                // Start calibration button
                if !isCalibrating && !calibrationCompleted {
                    Button("Start Calibration") {
                        startCalibration()
                    }
                    .bold()
                    .padding()
                    .frame(width: 200)
                    .buttonStyle(.borderedProminent)
                }
                
                // Control buttons
                HStack {
                    if calibrationStep > 0 || isCalibrating {
                        Button("Skip Calibration") {
                            stopCalibration()
                            navigateToHome()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if calibrationCompleted {
                        Button("Finish") {
                            navigateToHome()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
            .navigationTitle("Calibration Step \(calibrationStep + 1)")
            .onDisappear { stopCalibration() }
        }
    }
    
    private func startCalibration() {
        guard calibrationStep < calibrationPostures.count else { return }
        calibrationValues.removeAll()
        countdown = 10
        isCalibrating = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
                calibrationValues.append(postureManager.currentPitch)
            } else {
                stopCalibration()
                saveCalibrationStep()
            }
        }
    }
    
    private func stopCalibration() {
        timer?.invalidate()
        timer = nil
        isCalibrating = false
    }
    
    private func saveCalibrationStep() {
        guard !calibrationValues.isEmpty else {
            showAveragePitch = false
            return
        }
        
        let averagePitch = calibrationValues.reduce(0, +) / Double(calibrationValues.count)
        let averageRoll = postureManager.currentRoll
        
        postureManager.saveCalibration(
            posture: calibrationPostures[calibrationStep].0,
            pitch: averagePitch,
            roll: averageRoll
        )
        
        if calibrationStep < calibrationPostures.count - 1 {
            calibrationStep += 1
            isCalibrating = false
            showAveragePitch = true
        } else {
            calibrationCompleted = true
        }
    }
    
    private func navigateToHome() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: HomeView())
            window.makeKeyAndVisible()
        }
    }
    
    private func colorForStep(_ step: Int) -> Color {
        switch step {
        case 0: return .orange
        case 1: return .green
        case 2: return .blue
        default: return .gray
        }
    }
}
