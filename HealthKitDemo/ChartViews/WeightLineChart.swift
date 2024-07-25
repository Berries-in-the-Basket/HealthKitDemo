//
//  WeightLineChart.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 24.07.24.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    var selectedStat: HealthMetric
    var chartData: [HealthData]
    
    var minValue: Double{
        chartData.map{ $0.value }.min() ?? 0
    }
    
    var body: some View {
        VStack{
            NavigationLink(value: selectedStat){
                HStack{
                    VStack(alignment: .leading){
                        Label("Weight", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.green)
                        Text("Avg: 180 lbs")
                            .font(.caption)
                    }
                }
                Spacer()
                
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.secondary)
            
            Chart{
                RuleMark(y: .value("Weight Goal", 155))
                    .foregroundStyle(.indigo)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                
                ForEach(chartData){weight in
                    AreaMark(x: .value("Day", weight.date, unit: .day), yStart: .value("Value", weight.value), yEnd: .value("Min Value", minValue))
                        .foregroundStyle(Gradient(colors: [.green.opacity(0.5), .clear]))
                        .interpolationMethod(.catmullRom)
                    
                    LineMark(x: .value("Day", weight.date, unit: .day), y: .value("Value", weight.value))
                        .foregroundStyle(Color.green)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                }
            }
            .frame(height: 150)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis{
                AxisMarks{
                    AxisValueLabel(format: .dateTime.day().month(.defaultDigits))
                }
            }
            .chartYAxis {
                AxisMarks{value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
