//
//  HealthData.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 31.05.24.
//

import Foundation

struct HealthData: Identifiable{
    let id = UUID()
    let date: Date
    let value: Double
    
    static var mockData: [HealthData]{
        var data: [HealthData] = []
        
        for i in 0..<28{
            let metric = HealthData(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!, value: .random(in: 4000...15000))
            data.append(metric)
        }
        return data
    }
}
