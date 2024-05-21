//
//  HealtKitAskPermissionView.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 21.05.24.
//

import SwiftUI
import HealthKitUI

struct HealtKitAskPermissionView: View {
    @Environment(HealthKitManager.self) var healthKitManager
    @Environment(\.dismiss) var dismiss
    @State var isShowingHealthAskKitPermissions = false
    
    var askForPermissionText = """
Give permission to use your Health data for this app.
"""
    
    var body: some View {
        VStack(spacing: 170){
            VStack(alignment: .leading, spacing: 20){
                Image(.appleHealtKitIcon)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.3), radius: 16)
                
                Text("Apple Healt Kit Integration")
                    .font(.title2).bold()
                
                Text(askForPermissionText)
                    .foregroundStyle(.secondary)
            }
            
            Button("Connect Apple Health"){
                isShowingHealthAskKitPermissions = true
            }
            .buttonStyle(.borderedProminent)
            
        }
        .padding(30)
        .healthDataAccessRequest(store: healthKitManager.store, shareTypes: healthKitManager.types, readTypes: healthKitManager.types, trigger: isShowingHealthAskKitPermissions) { result in
            switch result{
            case .success(_):
                dismiss()
            case .failure(_):
                //to do: handle failute state
                dismiss()
            }
        }
    }
}

#Preview {
    HealtKitAskPermissionView()
        .environment(HealthKitManager())
}
