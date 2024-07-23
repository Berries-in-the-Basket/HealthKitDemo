//
//  StepPieChart.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 23.07.24.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    var chartData: [WeekdayChartData]
    
    var body: some View {
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
            
            Chart{
                ForEach(chartData){weekday in
                    SectorMark(angle: .value("Average Staps", weekday.value), innerRadius: .ratio(0.618), angularInset: 1)
                        .foregroundStyle(.blue)
                        .cornerRadius(6)
                }
            }
            .frame(height: 240)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
    }
}

extension Date{
    var weekdayTitle: String{
        self.formatted(.dateTime.weekday(.wide))
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekedayCount(for: HealthData.mockData))
}
