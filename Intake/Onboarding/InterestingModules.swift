//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct InterestingModules: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    
    var body: some View {
        SequentialOnboardingView(
            title: "Medical Intake Forms Made Easy",
            subtitle: "Together we will summarize...",
            content: [
                SequentialOnboardingView.Content(
                    title: "Main reason for visit",
                    description: "What brings you in today? Identify your primary concerns."
                ),
                SequentialOnboardingView.Content(
                    title: "Medical History",
                    description: "Summarize your relevant medical history."
                ),
                SequentialOnboardingView.Content(
                    title: "Surgical History",
                    description: "Summarize your surgical history."
                ),
                SequentialOnboardingView.Content(
                    title: "Medications",
                    description: "List your current medications."
                ),
                SequentialOnboardingView.Content(
                    title: "Allergies",
                    description: "List all your allgeries."
                ),
                SequentialOnboardingView.Content(
                    title: "Review of Systems",
                    description: "Other important questions."
                )
            ],
            actionText: "INTERESTING_MODULES_BUTTON",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        InterestingModules()
    }
}
#endif
