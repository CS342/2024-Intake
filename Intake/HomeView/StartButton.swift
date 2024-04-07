//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct StartButton: View {
    @Binding var navigationPath: NavigationPath
    
    
    var body: some View {
        Button(action: {
            if FeatureFlags.testMedication {
                navigationPath.append(NavigationViews.medication)
            } else if FeatureFlags.testAllergy {
                navigationPath.append(NavigationViews.allergies)
            } else if FeatureFlags.testMenstrual {
                navigationPath.append(NavigationViews.menstrual)
            } else if FeatureFlags.testSmoking {
                navigationPath.append(NavigationViews.smoking)
            } else if FeatureFlags.testSurgery {
                navigationPath.append(NavigationViews.surgical)
            } else if FeatureFlags.testCondition {
                navigationPath.append(NavigationViews.medical)
            } else {
                navigationPath.append(NavigationViews.general)
            }
        }) {
            Text("Create New Form")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(.accent)
                .cornerRadius(10)
        }.accessibilityIdentifier("Create New Form")
    }
}
