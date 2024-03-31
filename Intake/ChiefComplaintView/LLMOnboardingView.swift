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


/// Provide a basic onboarding view to submit OpenAI API Key
struct LLMOnboardingView: View {
    @Binding var showOnboarding: Bool

    
    var body: some View {
        OnboardingStack(onboardingFlowComplete: !$showOnboarding) {
            // OpenAI Onboarding
            LLMOpenAITokenOnboarding()

            // Local Onboarding
            // LLMLocalDownloadOnboarding()
        }
            .interactiveDismissDisabled(showOnboarding)
    }
}
