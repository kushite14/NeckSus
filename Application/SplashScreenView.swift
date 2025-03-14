//
//  SplashScreenView.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 06/03/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoOpacity = 0.0
    @State private var isActive = false
    @State private var showAppName = false
    @State private var appNameOffset = CGSize(width: 0, height: -50)
    
    @EnvironmentObject var postureManager: PostureManager
    @EnvironmentObject var healthData: HealthDataManager
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Logo Animation
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .opacity(logoOpacity)
                .animation(.easeIn(duration: 3), value: logoOpacity)
            
            // App Name Text
            if showAppName {
                VStack(spacing: 10) {
                    Text("NeckSus")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(Color("gold"))
                    
                    Text("Your personal Neck posture guardian")
                        .font(.system(size: 30))
                        .italic()
                        .foregroundColor(Color("gold").opacity(0.8))
                }
                .offset(appNameOffset)
                .opacity(showAppName ? 1 : 0)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .onAppear {
            // Sequence 1: Logo fade-in
            withAnimation(.easeIn(duration: 1.5)) {
                logoOpacity = 1.0
            }
            
            // Sequence 2: Logo fade-out + text appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    logoOpacity = 0.0
                    showAppName = true
                    appNameOffset = .zero
                }
            }
            
            // Sequence 3: Transition to main view
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                isActive = true
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                HomeView()
                    .environmentObject(postureManager)
                    .onAppear {
                        postureManager.startBackgroundServices()
                    }
                    .transition(.move(edge: .bottom))
            } else {
                CalibrationView()
                    .environmentObject(postureManager)
                    .onDisappear {
                        postureManager.startBackgroundServices()
                    }
            }
        }
    }
}
