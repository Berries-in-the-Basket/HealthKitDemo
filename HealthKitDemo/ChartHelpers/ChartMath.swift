//
//  ChartMath.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 22.07.24.
//

import Foundation
import Algorithms

struct ChartMath{
    static func averageWeekedayCount(for metric: [HealthData]) -> [WeekdayChartData]{
        let dataSortedByWeekday = metric.sorted{ $0.date.weekdayInt < $1.date.weekdayInt }
        //creates array of subarrays with data for each weekday (for 7 days - 7 subarrays)
        let weekdays = dataSortedByWeekday.chunked{ $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekdayChartData: [WeekdayChartData] = []
        
        for day in weekdays{
            guard let firstValue = day.first else {continue}
            //calculates total amount of steps for a given day
            let total = day.reduce(0) { $0 + $1.value}
            let averageSteps = total/Double(day.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: averageSteps))
        }
        return weekdayChartData
    }
    
    static func averageDailyWeightDifferences(weights: [HealthData]) -> [WeekdayChartData]{
        var diffValues: [(date: Date, value: Double)] = []
        
        for i in 1..<weights.count{
                let sampleDate = weights[i].date
                let difference = weights[i].value - weights[i - 1].value
                diffValues.append((date: sampleDate, value: difference))
        }
        
        let dataSortedByWeekday = diffValues.sorted{ $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdays = dataSortedByWeekday.chunked{ $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekdayChartData: [WeekdayChartData] = []
        
        for day in weekdays{
            guard let firstValue = day.first else {continue}
            //calculates total weight for a given day
            let total = day.reduce(0) { $0 + $1.value}
            let averageWeightDifference = total/Double(day.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: averageWeightDifference))
        }
        
        return weekdayChartData
    }
}

extension Date{
    var weekdayInt: Int{
        Calendar.current.component(.weekday, from: self)
    }
}
