// PainMainTab.swift
//  NeckSus13
//  Updated with 3D futuristic styling for buttons

import SwiftUI

struct PainMainTab: View {
    @EnvironmentObject var postureManager: PostureManager
    @EnvironmentObject var healthData: HealthDataManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    // State Properties
    @State private var selectedPainLevel: Int = 0
    @State private var notes: String = ""
    @State private var navigateToPainEntry = false
    @State private var navigateToPainMarking = false
    @State private var showStartDatePrompt = false
    @State private var markedPoints: [MarkedPoint] = []
    @State private var selectedHistoryOptions: [String] = []
    
    // Gesture States
    @GestureState private var markLocationPressed = false
    @GestureState private var logDetailsPressed = false
    @GestureState private var reviewHistoryPressed = false

    var body: some View {
        ZStack {
            // Background Image
            Image("PMtab")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 8)
                .overlay(Color.black.opacity(0.3))
            
            // Main Content
            VStack(spacing: 30) {
                futuristicButton(
                    destination: "PainMarkingView",
                    label: "Mark Pain Location",
                    icon: "mappin.circle",
                    gestureState: $markLocationPressed
                )
                
                futuristicButton(
                    destination: "PainEntryDetails",
                    label: "Log Pain Details",
                    icon: "doc.text.fill",
                    gestureState: $logDetailsPressed
                )
                
                futuristicButton(
                    destination: "PainHistoryReview",
                    label: "Review History",
                    icon: "clock.arrow.circlepath",
                    gestureState: $reviewHistoryPressed
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - 3D Futuristic Button Component
    private func futuristicButton(
        destination: String,
        label: String,
        icon: String,
        gestureState: GestureState<Bool>
    ) -> some View {
        NavigationLink(value: destination) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text(label)
                    .font(.custom("Avenir Next", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.blue.opacity(0.6), radius: 10, x: 5, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
            )
            .scaleEffect(gestureState.wrappedValue ? 0.95 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0), value: gestureState.wrappedValue)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.1)
                .updating(gestureState) { value, state, _ in
                    state = value
                }
        )
    }
}

// MARK: - Preview
struct PainMainTab_Previews: PreviewProvider {
    static var previews: some View {
        PainMainTab(navigationPath: .constant(NavigationPath()))
            .environmentObject(PostureManager(userSettings: UserSettings()))
            .environmentObject(HealthDataManager())
    }
}
