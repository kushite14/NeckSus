//
//  PostureVerificationView.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 13/02/2025.
//

import SwiftUI

struct PostureVerificationView: View {
    @EnvironmentObject var postureManager: PostureManager // ✅ Corrected EnvironmentObject wrapper issue
    let imageName: String

    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)
                .padding(.horizontal)

            Text("Does this posture look correct?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()

            HStack(spacing: 20) {
                Button(action: {
                    logPosture(isCorrect: true)
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Yes")
                            .fontWeight(.bold)
                    }
                    .frame(width: 140, height: 50)
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                Button(action: {
                    logPosture(isCorrect: false)
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("No")
                            .fontWeight(.bold)
                    }
                    .frame(width: 140, height: 50)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding(.top, 10)

            Spacer()

            Button(action: {
                reviewPostureHistory()
            }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Review Past Entries")
                        .fontWeight(.bold)
                }
                .frame(width: 220, height: 50)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .navigationTitle("Posture Verification")
    }

    // ✅ FIX: Wrapper Function to Call logVerifiedPosture
    private func logPosture(isCorrect: Bool) {
        postureManager.logVerifiedPosture(imageName: imageName, isCorrect: isCorrect)
    }

    // ✅ FIX: Wrapper Function to Call reviewPostureData
    private func reviewPostureHistory() {
        postureManager.reviewPostureData()
    }
}
