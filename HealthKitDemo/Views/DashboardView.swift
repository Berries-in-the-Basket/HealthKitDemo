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
            }
            .padding()
            .onAppear(perform: {
                isShowingHealtKitAskPermissionView = !wasHealthKitAskPermissionViewDisplayed
            })
            .task{
                //commented out for future use
                //                await healthKitManager.addData()
                
                await healthKitManager.fetchStepCount()
                ChartMath.averageWeekedayCount(for: healthKitManager.stepData)
                await healthKitManager.fetchWeightData()
                await healthKitManager.fetchWeightDataForAverageDifferentials()
                ChartMath.averageDailyWeightDifferences(weights: healthKitManager.weightDifferentialsData)
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
