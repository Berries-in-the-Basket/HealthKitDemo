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
final class HealthKitManager: Sendable{
    let store = HKHealthStore()
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    var stepData: [HealthData] = []
    var weightData: [HealthData] = []
    var weightDifferentialsData: [HealthData] = []
    var isAuthorized: Bool = false

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "Health data not available on this device"])
        }
        // On recent SDKs, HealthKit has an async API:
        try await store.requestAuthorization(toShare: types, read: types)
        // After request, check status for at least one type you need
        if let stepAuth = try? await store.statusForAuthorizationRequest(toShare: [HKQuantityType(.stepCount)], read: [HKQuantityType(.stepCount)]),
           case .unnecessary = stepAuth {
            // Already authorized earlier
            isAuthorized = true
        } else {
            // Alternatively, inspect authorization status per type
            let stepStatus = store.authorizationStatus(for: HKQuantityType(.stepCount))
            let weightStatus = store.authorizationStatus(for: HKQuantityType(.bodyMass))
            isAuthorized = (stepStatus == .sharingAuthorized || stepStatus == .notDetermined) && (weightStatus == .sharingAuthorized || weightStatus == .notDetermined)
            // Better: check reading status by trying a query; for simplicity, mark true if not denied.
            isAuthorized = stepStatus != .sharingDenied && weightStatus != .sharingDenied
        }
    }
    
    func addData() async{
        // Guard authorization
        guard isAuthorized else { return }
        var mockSamples: [HKQuantitySample] = []
        
        for i in 0..<28{
            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            let endDate = startDate
            
            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4000...20000))
            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
            mockSamples.append(stepSample)
            
            let weightValue = Double.random(in: (160 + Double(i/3)...165 + Double(i/3)))
            let weightQantity = HKQuantity(unit: .pound(), doubleValue: weightValue)
            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQantity, start: startDate, end: endDate)
            mockSamples.append(weightSample)
        }
        do {
            try await store.save(mockSamples)
        } catch {
            // Handle/save error if needed
            print("Failed to save samples: \(error)")
        }
    }
    
    func fetchStepCount() async{
        guard isAuthorized else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)
        
        let periodToFetchDataFor = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let dataForRequestedPeriod = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: periodToFetchDataFor)
        
        let stepsCountsQuery = HKStatisticsCollectionQueryDescriptor(predicate: dataForRequestedPeriod, options: .cumulativeSum, anchorDate: endDate, intervalComponents: .init(day: 1))
        
        do {
            let stepsCounts = try await stepsCountsQuery.result(for: store)
            stepData = stepsCounts.statistics().map{
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch {
            print("Failed to fetch steps: \(error)")
        }
    }
    
    func fetchStepCountForAI() async throws -> [HealthData] {
            guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
                throw STError.authNotDetermined
            }

            let interval = createDateInterval(from: .now, daysBack: 28)
            let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
            let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
            let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                                   options: .cumulativeSum,
                                                                   anchorDate: interval.end,
                                                                   intervalComponents: .init(day: 1))
            do {
                let stepCounts = try await stepsQuery.result(for: store)
                return stepCounts.statistics().map {
                    .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                }
            } catch HKError.errorNoData {
                throw STError.noData
            } catch {
                throw STError.unableToCompleteRequest
            }
        }
    
    func fetchWeightData() async{
        guard isAuthorized else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)
        
        let periodToFetchDataFor = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let dataForRequestedPeriod = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: periodToFetchDataFor)
        
        let weightDataQuery = HKStatisticsCollectionQueryDescriptor(predicate: dataForRequestedPeriod, options: .mostRecent, anchorDate: endDate, intervalComponents: .init(day: 1))
        
        do {
            let weightRawData = try await weightDataQuery.result(for: store)
            weightData = weightRawData.statistics().map{
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch  {
            print("Failed to fetch weight: \(error)")
        }
    }
    
    func fetchWeightsForAI(daysBack: Int) async throws -> [HealthData] {
            guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
                throw STError.authNotDetermined
            }

            let interval = createDateInterval(from: .now, daysBack: daysBack)
            let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
            let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
            let weightQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                                    options: .mostRecent,
                                                                    anchorDate: interval.end,
                                                                    intervalComponents: .init(day: 1))

            do {
                let weights = try await weightQuery.result(for: store)
                return weights.statistics().map {
                    .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
                }
            } catch HKError.errorNoData {
                throw STError.noData
            } catch {
                throw STError.unableToCompleteRequest
            }
        }
    
    func fetchWeightDataForAverageDifferentials() async{
        guard isAuthorized else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)
        
        let periodToFetchDataFor = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let dataForRequestedPeriod = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: periodToFetchDataFor)
        
        let weightDataQuery = HKStatisticsCollectionQueryDescriptor(predicate: dataForRequestedPeriod, options: .mostRecent, anchorDate: endDate, intervalComponents: .init(day: 1))
        
        do {
            let weightRawData = try await weightDataQuery.result(for: store)
            weightDifferentialsData = weightRawData.statistics().map{
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch  {
            print("Failed to fetch weight differentials: \(error)")
        }
    }
    
    private func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
            let calendar = Calendar.current
            let startOfEndDate = calendar.startOfDay(for: date)
            let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
            let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endDate)!
            return .init(start: startDate, end: endDate)
        }

}

