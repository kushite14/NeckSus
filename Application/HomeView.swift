import SwiftUI

struct HomeView: View {
    @EnvironmentObject var postureManager: PostureManager
    @EnvironmentObject var healthData: HealthDataManager
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView {
                OverviewTab()
                    .tabItem {
                        Label("Overview", systemImage: "house.fill")
                    }
                
                // 2. Pain Log Tab
                // In HomeView.swift ▼
                PainMainTab(navigationPath: $navigationPath) // Add binding// Renamed from PainLog for consistency
                    .tabItem {
                        Label("Pain Log", systemImage: "plus.circle")
                    }
                
                // 3. Profile Tab
                UserProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                
                // 4. Calibration Tab
                CalibrationView()
                    .tabItem {
                        Label("Calibrate", systemImage: "gearshape.fill")
                    }
                
                // 5. Analytics Tab (version-safe)
                AnalyticsWrapperView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                    }
                
                // 6. Performance Tab
                PerformanceView()
                    .tabItem { Label("Performance", systemImage: "chart.pie") } // Updated icon
                
            }
            .environmentObject(postureManager) // ✅ Explicitly passing environment object
            .environmentObject(healthData)    // ✅ Ensure all required objects are passed
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "PainMarkingView":
                    PainMarkingView(navigationPath: $navigationPath)
                case "PainEntryDetails":
                    PainEntryDetails()  // Ensure this view uses environment navigation
                default:
                    EmptyView()
                }
            }
        }
    }
    
}
