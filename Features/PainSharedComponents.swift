//
//  PainSharedComponents.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 12/03/2025.
//
import SwiftUI

struct PainLevelPicker: View {
    @Binding var painLevel: Int
    
    var body: some View {
        VStack {
            Text("Pain Level: \(painLevel)")
                .font(.headline)
            
            Slider(value: Binding<Double>(
                get: { Double(painLevel) },
                set: { painLevel = Int($0) }
            ), in: 0...10, step: 1)
        }
        .padding()
    }
}

struct MultiSelectPicker: View {
    let title: String
    let options: [String]
    @Binding var selection: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if selection.contains(option) {
                        selection.removeAll { $0 == option }
                    } else {
                        selection.append(option)
                    }
                }) {
                    HStack {
                        Text(option)
                        Spacer()
                        if selection.contains(option) {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

