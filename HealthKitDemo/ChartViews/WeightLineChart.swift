//
//  WeightLineChart.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 24.07.24.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    @State private var selectedDate: Date?
    
    var selectedStat: HealthMetric
    var chartData: [HealthData]
    
    var minValue: Double{
        chartData.map{ $0.value }.min() ?? 0
    }
    
    var selectedHealthMetric: HealthData?{
        guard let selectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
        
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
                if let selectedHealthMetric{
                    RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)){ annotationView }
                }
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
            .chartXSelection(value: $selectedDate)
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
    
    var annotationView: some View{
        VStack(alignment: .leading){
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.green)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2)
        )
    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
