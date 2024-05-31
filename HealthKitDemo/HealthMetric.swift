//
//  HealthMetric.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 31.05.24.
//

import Foundation

struct HealthData: Identifiable{
    let id = UUID()
    let date: Date
    let value: Double
}
