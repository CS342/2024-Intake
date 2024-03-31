//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SettingsButton: View {
    @Binding var showSettings: Bool
    
    
    var body: some View {
        Button(
            action: {
                showSettings.toggle()
            },
            label: {
                Image(systemName: "gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                    .accessibilityLabel("SETTINGS")
            }
        )
    }
}
