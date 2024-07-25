//
//  StepPieChart.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 23.07.24.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    @State private var selectedChartValue: Double? = 0
    
    var chartData: [WeekdayChartData]
    
    var selectedWeekday: WeekdayChartData?{
        guard let selectedChartValue else { return nil }
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return selectedChartValue <= total
        }
    }
    
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
                    SectorMark(angle: .value("Average Staps", weekday.value), 
                               innerRadius: .ratio(0.618),
                               outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
                               angularInset: 1)
                        .foregroundStyle(.blue)
                        .cornerRadius(6)
                        .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1.0 : 0.3)
                }
            }
            .chartAngleSelection(value: $selectedChartValue.animation(.easeInOut))
            .frame(height: 240)
            .chartBackground { proxy in
                GeometryReader { reader in
                    if let plotFrame = proxy.plotFrame{
                        let frame = reader[plotFrame]
                        if let selectedWeekday{
                            VStack{
                                Text(selectedWeekday.date.weekdayTitle)
                                    .font(.title3.bold())
                                    .contentTransition(.identity)
                                
                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
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
    StepPieChart(chartData: ChartMath.averageWeekedayCount(for: MockData.steps))
}
