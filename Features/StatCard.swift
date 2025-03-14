//
//  StatCard.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 13/02/2025.
//
import SwiftUI

struct StatCard: View {
    var title: String
    var value: String
    var iconName: String
    var description: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.largeTitle)
            Text(title)
                .font(.headline)
            Text(value)
                .font(.title)
                .bold()
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
