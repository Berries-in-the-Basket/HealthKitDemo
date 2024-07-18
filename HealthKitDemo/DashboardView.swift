//
//  DashboardView.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 17.05.24.
//

import SwiftUI
import Charts

enum HealthMetric: CaseIterable, Identifiable{
    var id: Self {self}
    
    case steps, weight
    
    var title: String{
        switch self{
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
    
    var navigationTint: Color{
        switch self{
        case .steps:
            return Color.blue
        case .weight:
            return Color.green
        }
    }
}

struct DashboardView: View {
    @Environment(HealthKitManager.self) var healthKitManager
    @AppStorage("wasHealthKitAskPermissionViewDisplayed") private var wasHealthKitAskPermissionViewDisplayed = false
    @State private var isShowingHealtKitAskPermissionView = true
    @State private var selectedStat: HealthMetric = .steps
    @State private var chartRawSelectedDate: Date?
    
    var averageStepCount: Double{
        guard !healthKitManager.stepData.isEmpty else { return 0 }
        let totalSteps = healthKitManager.stepData.reduce(0){ $0 + $1.value }
        return totalSteps/Double(healthKitManager.stepData.count)
    }
    
    var selectedHealthMetric: HealthData?{
        guard let chartRawSelectedDate else { return nil }
        let selectedMetric = healthKitManager.stepData.first {
            Calendar.current.isDate(chartRawSelectedDate, inSameDayAs: $0.date)
        }
        return selectedMetric
    }
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 20){
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetric.allCases) { metric in
                            Text(metric.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    VStack{
                        NavigationLink(value: selectedStat){
                            HStack{
                                VStack(alignment: .leading){
                                    Label("Steps", systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(.blue)
                                    Text("Avg: \(Int(averageStepCount)) steps")
                                        .font(.caption)
                                }
                            }
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.secondary)
                        
                        Chart{
                            if let selectedHealthMetric{
                                RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                                    .foregroundStyle(Color.secondary.opacity(0.3))
                                    .offset(y: -10)
                            }
                            RuleMark(y: .value("Average", averageStepCount))
                                .foregroundStyle(Color.secondary)
                                .lineStyle(.init(lineWidth: 1, dash: [5]))
                            
                            ForEach(healthKitManager.stepData) { steps in
                                BarMark(x: .value("Date", steps.date, unit: .day),
                                        y: .value("Steps", steps.value)
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }
                        }
                        .frame(height: 150)
                        .chartXSelection(value: $chartRawSelectedDate)
                        .chartXAxis{
                            AxisMarks{
                                AxisValueLabel(format: .dateTime.day().month(.defaultDigits))
                            }
                        }
                        .chartYAxis {
                            AxisMarks{value in
                                AxisGridLine()
                                    .foregroundStyle(Color.secondary.opacity(0.3))
                                AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                            }
                        }
                        
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Label("Averages", systemImage: "calendar")
                                .font(.title3.bold())
                                .foregroundStyle(.blue)
                            Text("Last 28 Days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 250)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
                }
            }
            .padding()
            .onAppear(perform: {
                isShowingHealtKitAskPermissionView = !wasHealthKitAskPermissionViewDisplayed
            })
            .task{
                //commented out for future use
//                await healthKitManager.addData()
                
                await healthKitManager.fetchStepCount()
//                await healthKitManager.fetchWeightData()
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetric.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingHealtKitAskPermissionView, onDismiss: {
                // to do fetch health kit data
            }, content: {
                HealtKitAskPermissionView(wasDisplayed: $wasHealthKitAskPermissionViewDisplayed)
            })
        }
        .tint(selectedStat.navigationTint)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
