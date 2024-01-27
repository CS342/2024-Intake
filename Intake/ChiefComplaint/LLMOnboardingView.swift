//
//  LLMOnboardingView.swift
//  Intake
//
//  Created by Nick Riedman on 1/25/24.
//

import SpeziLLMOpenAI
import SpeziOnboarding
import SwiftUI

// Provide a basic onboarding view to submit OpenAI API Key
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
