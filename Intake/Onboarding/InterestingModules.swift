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
            title: "The Intake Process",
            subtitle: "Intake works in 3 simple steps...",
            content: [
                SequentialOnboardingView.Content(
                    title: "Log in to Firebase",
                    description: "Sign in or make an account so we can keep your information secure and accessible."
                ),
                SequentialOnboardingView.Content(
                    title: "Explain your Chief Complaint",
                    // Want to add, but makes me fail pull request tests: What brings you in today?
                    description: "Give us an English description, and our AI model will summarize the key points."
                ),
                SequentialOnboardingView.Content(
                    title: "Complete intake info",
                    description: "With the help of our AI model, fill in electronic form with medical history, contact info, etc."
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
