//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziLLMOpenAI
import SpeziOnboarding
import SwiftUI

/// Onboarding view that gets the OpenAI token from the user.
struct LLMOpenAITokenOnboarding: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        LLMOpenAIAPITokenOnboardingStep {
            onboardingNavigationPath.nextStep()
        }
    }
}


#Preview {
    OnboardingStack {
        LLMOpenAITokenOnboarding()
    }
}
