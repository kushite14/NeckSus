import SwiftUI
import Charts

struct PostureSummaryChart: View {
    var data: [IdentifiableDateValue]
    var period: String

    private var startDate: Date
    private var endDate: Date

    // MARK: - UPDATED: Unified initialization
    init(data: [IdentifiableDateValue], period: String) {
        self.data = data
        self.period = period
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case "Day":
            startDate = calendar.startOfDay(for: now)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        case "Week":
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        case "Month":
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        default:
            startDate = now
            endDate = now
        }
    }

    var body: some View {
        Chart {
            // MARK: - UNCHANGED: Background zones for visualizing posture angles
            RectangleMark(xStart: .value("Start", startDate), xEnd: .value("End", endDate),
                          yStart: .value("Min", 0), yEnd: .value("Max", 30)).foregroundStyle(.red.opacity(0.5))
            
            RectangleMark(xStart: .value("Start", startDate), xEnd: .value("End", endDate),
                          yStart: .value("Min", 30), yEnd: .value("Max", 60)).foregroundStyle(.yellow.opacity(0.5))
            
            RectangleMark(xStart: .value("Start", startDate), xEnd: .value("End", endDate),
                          yStart: .value("Min", 60), yEnd: .value("Max", 90)).foregroundStyle(.green.opacity(0.5))
            
            // MARK: - UNCHANGED: Posture tracking data plotted over time
            ForEach(data) { entry in
                LineMark(x: .value("Time", entry.date), y: .value("Pitch", entry.value))
                    .foregroundStyle(.blue)
                    .symbol(.circle)
            }

            // MARK: - RESTORED: Horizontal Guidelines (Previously Removed)
            RuleMark(y: .value("30", 30))
                .foregroundStyle(.gray)
                .lineStyle(StrokeStyle(dash: [5]))
            
            RuleMark(y: .value("60", 60))
                .foregroundStyle(.gray)
                .lineStyle(StrokeStyle(dash: [5]))
        }
        .chartYScale(domain: 0...90)
        .chartXScale(domain: startDate...endDate)
        .chartXAxis {
            AxisMarks(values: .stride(by: period == "Day" ? .hour : .day)) { value in
                AxisValueLabel(format: period == "Day" ? .dateTime.hour() : .dateTime.day())
            }
        }
        .frame(height: 300)
        .padding()
    }
}
