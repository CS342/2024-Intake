//
//  LLMInteraction.swift
//  Intake
//
//  Created by Nick Riedman on 1/25/24.
//

import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SwiftUI

struct LLMInteraction: View {
    @Binding var presentingAccount: Bool
    
    @State var showOnboarding = true
    @State var model: LLM = LLMOpenAI(
        parameters: .init(
            modelType: .gpt4_1106_preview,
            systemPrompt: """
                You are acting as an intake person at a clinic and need to work with\
                the patient to help clarify their chief complaint into a concise,\
                specific complaint which includes elements of laterality if\
                appropriate, as well as severity and duration.\
                
                Please begin with a kind welcome message: "Welcome! What is the main reason for your visit?"\
                Please use everyday layman terms and avoid using complex medical terminology.\
                Only ask one question or prompt at a time, and keep your responses brief (one to two short sentences).
            """
        )
    )
    
    var body: some View {
        NavigationStack {
            LLMChatView(
                model: model
            )
            .navigationTitle("Chief Complaint")
            .toolbar {
                if AccountButton.shouldDisplay {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .sheet(isPresented: $showOnboarding) {
                LLMOnboardingView(showOnboarding: $showOnboarding)
            }
        }
    }
}


#Preview {
    LLMInteraction(presentingAccount: .constant(true))
        .previewWith {
            LLMRunner {
                LLMLocalRunnerSetupTask()
                LLMOpenAIRunnerSetupTask()
            }
        }
}
