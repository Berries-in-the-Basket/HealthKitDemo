//
//  CompatibilityModifiers.swift
//  HealthKitDemo
//
//  Created by You on 2025-10-29.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func applyCompatibleButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
    
    // Add more iOS 26 gated helpers here as needed, e.g.:
    // @ViewBuilder
    // func applyCompatibleSomeNewModifier() -> some View {
    //     if #available(iOS 26.0, *) {
    //         self.someNewModifier()
    //     } else {
    //         self // or an older equivalent fallback
    //     }
    // }
}
