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
    
    //check Apple Intelligence enabled?
    var isAvailable: Bool {
        switch model.availability {
        case .available:
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
    
    private init() {}
}

@available(iOS 26.0, *)
#Playground{
    let session = LanguageModelSession()
    let prompt = "When did Henry the 8th die?"
    
    do{
        let response = try await session.respond(to: prompt)
        print(response.content)
    }catch{
        print(error)
    }
}

