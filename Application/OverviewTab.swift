//
//  OverviewTab.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 11/03/2025.
//
// OverviewTab.swift
import SwiftUI

struct OverviewTab: View {
    @EnvironmentObject var postureManager: PostureManager
    @EnvironmentObject var healthData: HealthDataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 20) {
                    // **App Logo**
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .shadow(radius: 8)
                        .padding(.top, 30)
                    
                    
                    Text("Welcome to NeckSus")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.top, 10)
                    
                    Divider().padding(.horizontal, 40)
                    
                    
                    VStack(spacing: 15) {
                        StatCard(
                            title: "Alerts Triggered",
                            value: "\(postureManager.alertCount)",
                            iconName: "bell.fill",
                            description: "Triggered after 5+ min of screen usage"
                        )
                        
                        StatCard(
                            title: "Pain Logs",
                            value: "\(healthData.painLogs.count)",
                            iconName: "pencil",
                            description: "Total pain logs recorded"
                        )
                    }
                    .padding()
                    PerformanceView()
                        .frame(height: 300)
                        .padding()
                    
                    // Optional: Add "Detailed Analytics" button
                    NavigationLink(value: "Analytics") {
                        Text("View Detailed Analytics")
                            .font(.headline)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "Analytics" {
                    AnalyticsWrapperView() // Now accessible from Overview
                }
            }
        }
    }
}
