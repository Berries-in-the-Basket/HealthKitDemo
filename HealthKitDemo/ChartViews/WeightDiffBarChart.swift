//
//  WeightDiffBarChart.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 30.07.24.
//

import SwiftUI
import Charts

struct WeightDiffBarChart: View {
    @State private var chartRawSelectedDate: Date?
    
    var chartData: [WeekdayChartData]
    
    var selectedData: WeekdayChartData?{
        guard let chartRawSelectedDate else { return nil }
        let selectedMetric = chartData.first {
            Calendar.current.isDate(chartRawSelectedDate, inSameDayAs: $0.date)
        }
        return selectedMetric
    }
    
    var body: some View {
        VStack{
                HStack{
                    VStack(alignment: .leading){
                        Label("Average Weight Change", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.green)
                        Text("Per Weekday (Last 28 days)")
                            .font(.caption)
                    }
                    Spacer()
                }
            .foregroundStyle(.secondary)
            
            Chart{
                if let selectedData{
                    RuleMark(x: .value("Selected Data", selectedData.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)){ annotationView }
                }

                ForEach(chartData) { weightDiff in
                    BarMark(x: .value("Date", weightDiff.date, unit: .day),
                            y: .value("Weight", weightDiff.value)
                    )
                    .foregroundStyle(weightDiff.value >= 0 ? Color.green.gradient : Color.indigo.gradient)
                    .opacity(chartRawSelectedDate == nil || weightDiff.date == selectedData?.date ? 1.0 : 0.3)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $chartRawSelectedDate.animation(.easeInOut))
            .chartXAxis{
                AxisMarks(values: .stride(by: .day)){
                    AxisValueLabel(format: .dateTime.weekday(), centered: true)
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
    }
    
    var annotationView: some View{
        VStack(alignment: .leading){
            Text(selectedData?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text(selectedData?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle((selectedData?.value ?? 0) >= 0 ? .green : .indigo)
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
    WeightDiffBarChart(chartData: MockData.weightDiffs)
}
