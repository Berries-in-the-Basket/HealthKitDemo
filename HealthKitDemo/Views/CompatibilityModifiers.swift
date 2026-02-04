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

struct CustomSheet: ViewModifier{
    @Binding var isPresented: Bool
    let passedNamespace: Namespace.ID
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *){
            content.sheet(isPresented: $isPresented) {
                DataAnalyzer.shared.aiCoachMessage = ""
            } content: {
                AICoachView()
                    .presentationDetents([.fraction(0.8)])
                    .navigationTransition(.zoom(sourceID: "aiCoachView", in: passedNamespace))
            }
        }else{
            content
        }
    }
}

extension View{
    func customSheet(isPresented: Binding<Bool>, namespace: Namespace.ID) -> some View {
        self.modifier(CustomSheet(isPresented: isPresented, passedNamespace: namespace))
    }
}
