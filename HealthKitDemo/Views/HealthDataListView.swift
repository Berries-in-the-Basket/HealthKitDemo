//
//  HealthDataListView.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 17.05.24.
//

import SwiftUI

struct HealthDataListView: View {
    var metric: HealthMetric
    var backgroundColor: Color{
        metric == .steps ? .pink : .cyan
    }
    
    var body: some View {
        List(0..<5){ item in
            HStack{
                Text(Date().formatted())
                Spacer()
                Text("1000")
            }
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.35))
        }
        .navigationTitle(metric.title)
        .scrollContentBackground(.hidden)
        .background(LinearGradient(colors: [backgroundColor.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

#Preview {
    NavigationStack{
        HealthDataListView(metric: .steps)
    }
}
