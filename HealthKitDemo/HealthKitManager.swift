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
    var stepData: [HealthData] = []
    var weightData: [HealthData] = []
    
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
    
    func fetchStepCount() async{
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)
        
        let periodToFetchDataFor = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let dataForRequestedPeriod = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: periodToFetchDataFor)
        
        let stepsCountsQuery = HKStatisticsCollectionQueryDescriptor(predicate: dataForRequestedPeriod, options: .cumulativeSum, anchorDate: endDate, intervalComponents: .init(day: 1))
        
        let stepsCounts = try! await stepsCountsQuery.result(for: store)
        stepData = stepsCounts.statistics().map{
            .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
        }
    }
    
    func fetchWeightData() async{
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)
        
        let periodToFetchDataFor = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let dataForRequestedPeriod = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: periodToFetchDataFor)
        
        let weightDataQuery = HKStatisticsCollectionQueryDescriptor(predicate: dataForRequestedPeriod, options: .mostRecent, anchorDate: endDate, intervalComponents: .init(day: 1))
        
        let weightRawData = try! await weightDataQuery.result(for: store)
        weightData = weightRawData.statistics().map{
            .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
        }
    }
}
