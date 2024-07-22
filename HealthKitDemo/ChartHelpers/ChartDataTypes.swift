//
//  ChartDataTypes.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 22.07.24.
//

import Foundation

struct WeekdayChartData: Identifiable{
    let id = UUID()
    let date: Date
    let value: Double
}
