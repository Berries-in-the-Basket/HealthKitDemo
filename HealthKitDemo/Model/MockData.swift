//
//  MockData.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 24.07.24.
//

import Foundation

struct MockData {
    
    static var steps: [HealthData]{
        var data: [HealthData] = []
        
        for i in 0..<28{
            let metric = HealthData(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, value: .random(in: 4000...15000))
            data.append(metric)
        }
        return data
    }
    
    static var weights: [HealthData]{
        var data: [HealthData] = []
        
        for i in 0..<28{
            let metric = HealthData(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, value: .random(in: (160 + Double(i/3)...165 + Double(i/3))))
            data.append(metric)
        }
        return data
    }
    
    static var weightDiffs: [WeekdayChartData]{
        var data: [WeekdayChartData] = []
        
        for i in 0..<7{
            let diff = WeekdayChartData(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, value: .random(in: -3...3))
            data.append(diff)
        }
        return data
    }
}
