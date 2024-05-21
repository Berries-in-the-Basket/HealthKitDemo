//
//  HealthKitDemoApp.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 17.05.24.
//

import SwiftUI

@main
struct HealthKitDemoApp: App {
    let healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(healthKitManager)
        }
    }
}
