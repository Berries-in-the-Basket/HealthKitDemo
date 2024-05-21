//
//  HealtKitAskPermissionView.swift
//  HealthKitDemo
//
//  Created by Mariusz Smoliński on 21.05.24.
//

import SwiftUI

struct HealtKitAskPermissionView: View {
    
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
                //ask for permission
            }
            .buttonStyle(.borderedProminent)
            
        }
        .padding(30)
    }
}

#Preview {
    HealtKitAskPermissionView()
}
