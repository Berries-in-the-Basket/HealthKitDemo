//
//  ContentView.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 17.05.24.
//

import SwiftUI

enum HealthMetric: CaseIterable, Identifiable{
    var id: Self {self}
    
    case steps, weight
    
    var title: String{
        switch self{
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
    
    var navigationTint: Color{
        switch self{
        case .steps:
            return Color.blue
        case .weight:
            return Color.green
        }
    }
}

struct ContentView: View {
    @State private var selectedStat: HealthMetric = .steps
    
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 20){
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetric.allCases) { metric in
                            Text(metric.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    VStack{
                        NavigationLink(value: selectedStat){
                            HStack{
                                VStack(alignment: .leading){
                                    Label("Steps", systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(.blue)
                                    Text("Avg: 10k steps")
                                        .font(.caption)
                                }
                            }
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.secondary)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 150)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Label("Averages", systemImage: "calendar")
                                .font(.title3.bold())
                                .foregroundStyle(.blue)
                            Text("Last 28 Days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 250)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
                }
            }
            .padding()
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetric.self) { metric in
                Text(metric.title)
            }
        }
        .tint(selectedStat.navigationTint)
    }
}

#Preview {
    ContentView()
}
