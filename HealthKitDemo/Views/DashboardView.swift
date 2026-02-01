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
    
    var backgroundColor: Color{
        selectedStat == .steps ? .pink : .cyan
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
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChartView(selectedStat: selectedStat, chartData: healthKitManager.stepData)
                        StepPieChart(chartData: ChartMath.averageWeekedayCount(for: healthKitManager.stepData))
                    case .weight:
                        WeightLineChart(selectedStat: selectedStat, chartData: healthKitManager.weightData)
                        WeightDiffBarChart(chartData: ChartMath.averageDailyWeightDifferences(weights: healthKitManager.weightData))
                    }
                }
                .padding()
            }
            .onAppear {
                isShowingHealtKitAskPermissionView = !wasHealthKitAskPermissionViewDisplayed
            }
            .task {
                // If the sheet won't be shown (already displayed before), request programmatically
                if !isShowingHealtKitAskPermissionView {
                    do {
                        try await healthKitManager.requestAuthorization()
                        // Optionally seed mock data
                        await healthKitManager.addData()
                        await healthKitManager.fetchStepCount()
                        ChartMath.averageWeekedayCount(for: healthKitManager.stepData)
                        await healthKitManager.fetchWeightData()
                        await healthKitManager.fetchWeightDataForAverageDifferentials()
                        ChartMath.averageDailyWeightDifferences(weights: healthKitManager.weightDifferentialsData)
                    } catch {
                        // Handle denied or failed auth gracefully
                        print("HealthKit authorization failed: \(error)")
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbarTitleDisplayMode(.inlineLarge)
            .background(LinearGradient(colors: [backgroundColor.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            .navigationDestination(for: HealthMetric.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingHealtKitAskPermissionView, onDismiss: {
                // After the HealthKitUI sheet, try to fetch data
                Task {
                    do {
                        // Request programmatically as well to ensure state is set and isAuthorized flips
                        try await healthKitManager.requestAuthorization()
                        await healthKitManager.addData()
                        await healthKitManager.fetchStepCount()
                        await healthKitManager.fetchWeightData()
                        await healthKitManager.fetchWeightDataForAverageDifferentials()
                    } catch {
                        print("Authorization after sheet failed: \(error)")
                    }
                }
            }, content: {
                HealtKitAskPermissionView(wasDisplayed: $wasHealthKitAskPermissionViewDisplayed)
            })
            .toolbar{
                if #available(iOS 26.0, *){
                    if DataAnalyzer.shared.model.isAvailable {
                        Button("Analyze Data", systemImage: "apple.intelligence") {
                            print("Apple Intelligence is on")
                        }
                    }
                }
            }
        }
        .tint(selectedStat.navigationTint)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
