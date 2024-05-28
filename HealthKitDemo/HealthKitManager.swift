//
//  HealthKitManager.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 21.05.24.
//

import Foundation
import HealthKit
import Observation

@Observable 
class HealthKitManager{
    let store = HKHealthStore()
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    func addData() async{
        var mockSamples: [HKQuantitySample] = []
        
        for i in 0..<28{
            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            let endDate = startDate
            
            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4000...20000))
//            let endDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)
            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
            
            mockSamples.append(stepSample)
            
            let weightValue = Double.random(in: (160 + Double(i/3)...165 + Double(i/3)))
            let weightQantity = HKQuantity(unit: .pound(), doubleValue: weightValue)
            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQantity, start: startDate, end: endDate)
            
            mockSamples.append(weightSample)
        }
        try! await store.save(mockSamples)
    }
}
