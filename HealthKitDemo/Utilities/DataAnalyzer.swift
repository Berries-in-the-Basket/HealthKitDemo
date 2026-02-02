//
//  DataAnalyzer.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 04.11.25.
//

import Foundation
import FoundationModels
import Playgrounds

@available(iOS 26.0, *)
@Observable
final class DataAnalyzer{
    static let shared = DataAnalyzer()
    let model = SystemLanguageModel.default
    
    private init() {}
    
    //check Apple Intelligence enabled?
    var isAvailable: Bool {
        switch model.availability {
        case .available:
            print("model available")
            return true
        case .unavailable(.appleIntelligenceNotEnabled):
            print("not enabled")
            return false
        case .unavailable(.deviceNotEligible):
            print("device not eligible")
            return false
        case .unavailable(.modelNotReady):
            print("model not ready")
            return false
        case .unavailable(_):
            return false
        }
    }
    
    func analyseHealthData() async{
        let session = LanguageModelSession(
            tools: [HealthDataTool()],
            instructions: "You are a high-energy motivational fitness coach. You love to analyze step count and health data to motivate people to get fit."
        )
        
        let prompt = """
                Use the `fetchStepsAndWeight` tool to get stats about the user’s recent step count and weight. 
                Each stat is labeled with a value such as `stepsTotal: value`. The `numberOfStepDays` and `numberOfWeightDays` stats represent how many 
                days are in the dataset.

                Use these stats to share interesting insights with the user about their weight and step count data. Always 
                mention their highest step count day to highlight an achievement. Always mention the total weight lost or 
                gained and provide encouragement along with some healthy tips about weight loss.

                The output should be human readable, and easy to digest. It should read as if a fitness 
                coach is talking to the user and cheering on their fitness journey. Focus mostly on data and insights 
                with a touch of motivational language. Only use an emoji after the final line of your response.
        
        Give exact data for steps and weights.
        """
        
        do{
            let response = try await session.respond(to: prompt)
            print(response.content)
        } catch{
            print(error.localizedDescription)
        }
    }
}

@available(iOS 26.0, *)
struct HealthDataTool: Tool {
    typealias Output = String
    
    var name: String = "fetchStepsAndWeight"
    var description: String = "Fetch the user's step count and weight data from HealthKit"
    
    @Generable()
    struct Arguments {}

    func call(arguments: Arguments) async throws -> String {
        let healthKitManager = HealthKitManager()
        // Prefer returned values to avoid races; fall back to stored properties if empty
        let steps = try await healthKitManager.fetchStepCountForAI().map {$0.value}
        let weights = try await healthKitManager.fetchWeightsForAI(daysBack: 28).map {$0.value}
        
        
        let stepsHigh = Int(steps.max() ?? 0)
        let stepsLow = Int(steps.min() ?? 0)
        let stepsTotal = Int(steps.reduce(0, +))
        print(stepsTotal)
        let stepsAverage = Double(stepsTotal) / Double(steps.count)
        
        
        let weightHigh = Int(weights.max() ?? 0)
        let weightLow = Int(weights.min() ?? 0)
        let weightLoss = (weights.first ?? 0) - (weights.last ?? 0)
        
        return """
                    stepsHighestValue: \(stepsHigh),
                    stepsLowestValue: \(stepsLow),
                    stepsTotal: \(stepsTotal),
                    stepsAverage: \(stepsAverage),
                    weightHighestValue: \(weightHigh),
                    weightLowestValue: \(weightLow),
                    weightLoss: \(weightLoss),
                    numberOfStepDays: \(steps.count),
                    nuberOfWeightDays: \(weights.count)
            """
        
    }
}

@available(iOS 26.0, *)
#Playground{
    let session = LanguageModelSession()
    let prompt = "When did Henry the 8th die??"
    
    do{
        let response = try await session.respond(to: prompt)
        print(response.content)
    }catch{
        print(error)
    }
}

