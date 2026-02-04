//
//  AICoachView.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 04.02.26.
//

import SwiftUI

@available(iOS 26.0, *)
struct AICoachView: View {
    @Environment(\.dismiss) var dismiss
    let dataAnalyzer = DataAnalyzer.shared
    
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "figure.run.treadmill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    //.clipShape(.circle)
                
                Text("Your Personal Coach")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                Button("OK", systemImage: "checkmark"){
                    dismiss()
                }
                .padding(12)
                .labelStyle(.iconOnly)
                .clipShape(.circle)
                .glassEffect(.regular.tint(.orange).interactive())
            }
            
            ScrollView{
                Text(dataAnalyzer.aiCoachMessage ?? "")
                    .contentTransition(.interpolate)
                    .animation(.easeInOut(duration: 0.5), value: dataAnalyzer.aiCoachMessage)
            }
            .overlay{
                if dataAnalyzer.isAnalyzing {
                    VStack{
                        Image(systemName: "apple.intelligence")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .symbolEffect(.pulse, options: .repeat(.continuous))
                        Text("Analyzing...")
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                    .frame(width: 200)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

#Preview {
    AICoachView()
}
