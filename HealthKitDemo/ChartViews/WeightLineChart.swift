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
                ForEach(chartData){weight in
                    AreaMark(x: .value("Day", weight.date, unit: .day), y: .value("Value", weight.value))
                        .foregroundStyle(Gradient(colors: [.green.opacity(0.5), .clear]))
                    
                    LineMark(x: .value("Day", weight.date, unit: .day), y: .value("Value", weight.value))
                        .foregroundStyle(Color.green)
                }
            }
            .frame(height: 150)
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
