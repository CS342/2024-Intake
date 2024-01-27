//
//  LLMOpenAITokenOnboarding.swift
//  Intake
//
//  Created by Nick Riedman on 1/25/24.
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
