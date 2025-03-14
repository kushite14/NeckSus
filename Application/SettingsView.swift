//  NeckSus13
//
//  Created by Khalid Mukhtar

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var healthData: HealthDataManager

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Health Integration")) {
                    Button("Request HealthKit Access") {
                        healthData.requestAuthorization()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
