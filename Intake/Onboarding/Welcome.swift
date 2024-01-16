//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct Welcome: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    
    var body: some View {
        OnboardingView(
            title: "Welcome to Intake",
            subtitle: "Electronic medical forms made easy.",
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "list.bullet.clipboard")
                            .accessibilityHidden(true)
                    },
                    title: "Modernize Patient Experience",
                    description: "Digitally replicate the traditional patient intake form to ensure up-to-date health records"
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "heart.circle")
                            .accessibilityHidden(true)
                    },
                    title: "Integrate Medical History",
                    description: "Intake automatically extracts key information from HealthKit and patient input."
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "bubble")
                            .accessibilityHidden(true)
                    },
                    title: "Virtual Assistance",
                    description: "Our helpful AI survey assistant can answer clarifying questions."
                )
            ],
            actionText: "Get Started",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
            .padding(.top, 24)
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        Welcome()
    }
}
#endif
