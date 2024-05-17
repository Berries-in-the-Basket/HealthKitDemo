//
//  HealthDataListView.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 17.05.24.
//

import SwiftUI

struct HealthDataListView: View {
    var metric: HealthMetric
    
    var body: some View {
        List(0..<5){ item in
            HStack{
                Text(Date().formatted())
                Spacer()
                Text("1000")
            }
        }
        .navigationTitle(metric.title)
    }
}

#Preview {
    NavigationStack{
        HealthDataListView(metric: .steps)
    }
}
