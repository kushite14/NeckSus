//
//  PerformanceView.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 22/02/2025.
import SwiftUI
import Charts

struct PerformanceView: View {
    @EnvironmentObject var postureManager: PostureManager
    @State private var selectedPeriod: String = "Day"
    @State private var redTime: Double = 0
    @State private var yellowTime: Double = 0
    @State private var greenTime: Double = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Period Picker
                Picker("Period", selection: $selectedPeriod) {
                    Text("Day").tag("Day")
                    Text("Week").tag("Week")
                    Text("Month").tag("Month")
                }
                .pickerStyle(.segmented)
                .padding()
                
                
                Chart {
                    if let green = postureManager.greenPercentage,
                       let amber = postureManager.amberPercentage,
                       let red = postureManager.redPercentage {
                        if #available(iOS 17.0, *) {
                            SectorMark(angle: .value("Green", green), innerRadius: .ratio(0.5))
                                .foregroundStyle(.green)
                        } else {
                            // Fallback on earlier versions
                        }
                        if #available(iOS 17.0, *) {
                            SectorMark(angle: .value("Amber", amber), innerRadius: .ratio(0.5))
                                .foregroundStyle(.orange)
                        } else {
                            // Fallback on earlier versions
                        }
                        if #available(iOS 17.0, *) {
                            SectorMark(angle: .value("Red", red), innerRadius: .ratio(0.5))
                                .foregroundStyle(.red)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                .frame(height: 180)
                // Add the text below the chart
                VStack(spacing: 10) {
                    Text("How's your Neck today?")
                        .font(.system(size: UIScreen.main.bounds.width > 375 ? 18 : 16))
                        .italic()
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onAppear(perform: loadHourlyData) // ✅ Call function correctly
    }
                // Data Loading Function (Unchanged)
                private func loadHourlyData() {
                    let directory = FileManager.default.urls(
                        for: .documentDirectory,
                        in: .userDomainMask
                    )[0].appendingPathComponent("PostureData")

                    // Add this check:
                    if !FileManager.default.fileExists(atPath: directory.path) {
                        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                    }
                    
                    do {
                        let files = try FileManager.default.contentsOfDirectory(
                            at: directory,
                            includingPropertiesForKeys: [.creationDateKey],
                            options: .skipsHiddenFiles
                        )
                        
                        let sortedFiles = try files.sorted(by: {
                            let date1 = try $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date()
                            let date2 = try $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date()
                            return date1 < date2
                        })
                        
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        
                        var entries: [HourlyPostureEntry] = []
                        
                        for file in sortedFiles where file.pathExtension == "json" {
                            let data = try Data(contentsOf: file) // ✅ Initialize 'data' here
                            let entry = try decoder.decode(HourlyPostureEntry.self, from: data)
                            entries.append(entry)
                        }
                        
                        for file in sortedFiles where file.pathExtension == "json" {
                            _ = try Data(contentsOf: file) // Discard result
                            _ = HourlyPostureEntry(date: Date(), pitch: 0, roll: 0) // Discard result
                        }
                        
                        // Filter entries based on selected period
                        let calendar = Calendar.current
                        let now = Date()
                        let filteredEntries = entries.filter { entry in
                            switch selectedPeriod {
                            case "Day":
                                return calendar.isDate(entry.date, inSameDayAs: now)
                            case "Week":
                                return calendar.isDate(entry.date, equalTo: now, toGranularity: .weekOfYear)
                            case "Month":
                                return calendar.isDate(entry.date, equalTo: now, toGranularity: .month)
                            default:
                                return false
                            }
                        }
                        
                        // Calculate time in each zone
                        redTime = 0
                        yellowTime = 0
                        greenTime = 0
                        
                        filteredEntries.forEach { entry in
                            switch entry.pitch {
                            case 0..<30: redTime += 1
                            case 30..<60: yellowTime += 1
                            case 60...90: greenTime += 1
                            default: break
                            }
                        }
                        
                    } catch {
                        print("Failed to load data: \(error)")
                    }
                }
            }

