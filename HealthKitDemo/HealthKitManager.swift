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
}
