import SwiftUI
import Charts


// MARK: - Analytics View
@available(iOS 16.0, *)
struct AnalyticsView: View {
    @EnvironmentObject private var postureManager: PostureManager
    @EnvironmentObject private var healthData: HealthDataManager
    @State private var selectedPeriod = "Day"
    @State private var selectedDataType = "Posture"
    @State private var isExporting = false
    
    private var emptyDataView: some View {
        Text("No available data for this view")
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
    }

    private var invalidDataTypeView: some View {
        Text("Select a valid data type")
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                dataTypePicker
                periodPicker
                analyticsChart
            }
            .navigationTitle("Analytics")
            .toolbar { exportButton }
            .overlay(exportOverlay)
        }
    }
    
    // MARK: - View Components
    private var dataTypePicker: some View {
        Picker("Data Type", selection: $selectedDataType) {
            Text("Posture").tag("Posture")
            Text("Alerts").tag("Alerts")
            Text("Pain").tag("Pain")
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            Text("Day").tag("Day")
            Text("Week").tag("Week")
            Text("Month").tag("Month")
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var analyticsChart: some View {
        Group {
            switch selectedDataType {
            case "Posture", "Alerts", "Pain":
                if checkDataEmpty() {
                    emptyDataView
                } else {
                    chartContent
                }
            default:
                invalidDataTypeView
            }
        }
        .frame(minHeight: 300)
    }
    
    private var chartContent: some View {
        Group {
            if selectedDataType == "Posture" {
                PostureSummaryChart(
                    data: postureManager.groupedPostureData(for: selectedPeriod),
                    period: selectedPeriod
                )
            } else {
                Chart { chartMarks }
                    .chartYScale(domain: dataRange() ?? 0...100)
                    .chartXAxis { xAxis }
                    .chartYAxis { yAxis }
                    .chartYAxisLabel(yAxisLabel)
                    .padding()
            }
        }
    }
    
    @available(iOS 16.0, *)
    @ChartContentBuilder
    private var chartMarks: some ChartContent {
        switch selectedDataType {
        case "Alerts":
            ForEach(postureManager.groupedAlerts(for: selectedPeriod)) { alert in
                BarMark(
                    x: .value("Time", alert.date),
                    y: .value("Count", alert.value)
                )
                .foregroundStyle(.red)
            }
        case "Pain":
            ForEach(healthData.groupedPainLogs(for: selectedPeriod)) { log in
                BarMark(
                    x: .value("Date", log.date),
                    y: .value("Count", log.count)
                )
                .foregroundStyle(.green.opacity(0.3))
            }
        default:
            BarMark(x: .value("", Date()), y: .value("", 0))
                .opacity(0)
        }
    }
    
    // MARK: - Axis Components
    private var xAxis: some AxisContent {
        AxisMarks(values: .stride(by: timeInterval)) { value in
            AxisValueLabel {
                if selectedPeriod == "Day", let date = value.as(Date.self) {
                    Text(formatIntervalLabel(for: date))
                        .rotationEffect(.degrees(45))
                } else {
                    Text(value.as(String.self) ?? "")
                }
            }
        }
    }
    
    private var yAxis: some AxisContent {
        AxisMarks(position: .leading)
    }
    
    // MARK: - Helper Functions
    private func formatIntervalLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 0..<6: return "00:00 - 06:00"
        case 6..<12: return "06:00 - 12:00"
        case 12..<18: return "12:00 - 18:00"
        default: return "18:00 - 00:00"
        }
    }
    
    private var timeInterval: Calendar.Component {
        selectedPeriod == "Day" ? .hour : .day
    }
    
    private var yAxisLabel: String {
        switch selectedDataType {
        case "Posture": return "Pitch (degrees)"
        case "Alerts": return "Alert Count"
        case "Pain": return "Pain Entries"
        default: return ""
        }
    }
    
    private func checkDataEmpty() -> Bool {
        switch selectedDataType {
        case "Posture":
            return postureManager.groupedPostureData(for: selectedPeriod).isEmpty
        case "Alerts":
            return postureManager.groupedAlerts(for: selectedPeriod).isEmpty
        case "Pain":
            return healthData.groupedPainLogs(for: selectedPeriod).isEmpty
        default:
            return true
        }
    }
    
    private func dataRange() -> ClosedRange<Double>? {
        switch selectedDataType {
        case "Posture":
            return rangeValues(postureManager.groupedPostureData(for: selectedPeriod).map { $0.value })
        case "Alerts":
            return rangeValues(postureManager.groupedAlerts(for: selectedPeriod).map { $0.value })
        case "Pain":
            return rangeValues(healthData.groupedPainLogs(for: selectedPeriod).map { $0.count })
        default:
            return nil
        }
    }
    
    private func rangeValues(_ values: [Double]) -> ClosedRange<Double>? {
        guard let min = values.min(), let max = values.max() else { return nil }
        return min...max
    }
    
    // MARK: - Export Logic
    private var exportButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Export Data") {
                Task { await exportData() }
            }
            .disabled(isExporting)
        }
    }
    
    private var exportOverlay: some View {
        Group {
            if isExporting {
                ProgressView("Exporting...")
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
    
    private func exportData() async {
        isExporting = true
        defer { isExporting = false }
        
        do {
            let directory = try createExportDirectory()
            await MainActor.run {
                let controller = UIDocumentPickerViewController(forExporting: [directory])
                guard let rootVC = UIApplication.shared.rootViewController else { return }
                rootVC.present(controller, animated: true)
            }
        } catch {
            print("Export failed: \(error.localizedDescription)")
        }
    }
    
    private func createExportDirectory() throws -> URL {
        let directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("PostureData")
        
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }
}

// MARK: - Preview
struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .environmentObject(PostureManager(userSettings: UserSettings())) // Add param
            .environmentObject(HealthDataManager())
    }
}

// MARK: - UIApplication Extension
extension UIApplication {
    var rootViewController: UIViewController? {
        (connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
    }
}
struct AnalyticsWrapperView: View {
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                AnalyticsView()
            } else {
                Text("Analytics require iOS 16+")
            }
        }
    }
}
