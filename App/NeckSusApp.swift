import SwiftUI

@main
struct NeckSusApp: App {
    @StateObject private var bootstrapper = Bootstrapper()
    
    var body: some Scene {
        WindowGroup {
            // Passing the bootstrapper into the environment for Feature access
            ContentView()
                .environmentObject(bootstrapper)
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "figure.walk")
                .imageScale(.large)
            Text("NeckSus 14: Core Active")
                .font(.headline)
        }
        .padding()
    }
}