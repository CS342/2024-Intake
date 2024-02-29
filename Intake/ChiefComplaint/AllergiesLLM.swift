//
//  AllergiesLLM.swift
//  Intake
//
//  Created by Zoya Garg on 2/21/24.

// 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
import Foundation
import SpeziChat
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SwiftUI


// My head hurts. 10/10 pain. Sharp. Top of head. Hurts for a week. No triggers. Nothing makes it better or worse. No further information that I have
struct LLMAssistantView: View {
    @State var model: LLM
    @Binding var presentingAccount: Bool
    @State var showOnboarding = true
    @State var greeting = true
//    @Binding var pageTitle: String
//    @Binding var initialQuestion: String
//    @Binding var prompt: String
    @Environment(LLMRunner.self) var runner: LLMRunner
    
    var body: some View {
        NavigationView {
            LLMChatView(
                model: model
            )
            .sheet(isPresented: $showOnboarding) {
                LLMOnboardingView(showOnboarding: $showOnboarding)
            }
            .navigationTitle("Intake Form Assitant")
            .toolbar {  // Is this doing anything except causing problems?
                if AccountButton.shouldDisplay {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .onAppear {
                if greeting {
                    let assistantMessage = ChatEntity(role: .assistant, content: "Do you have any questions about your allergies?")
                    model.context.insert(assistantMessage, at: 0)
                }
                greeting = false
            }
        }
    }
    
    init(presentingAccount: Binding<Bool>) {
        // pageTitle: Binding<String>, initialQuestion: Binding<String>, prompt: Binding<String>
        
        self._presentingAccount = presentingAccount
        self.model = LLMOpenAI(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    // swiftlint:disable:next line_length
                    systemPrompt: "When responding to patient inquiries about allergies, focus on the following directives: Identify the allergen and reaction type: Provide concise information on the allergen involved and the type of reaction it causes (e.g., rash, anaphylaxis), limiting your response to no more than 1-2 sentences. Be direct and clear: Use straightforward language to define medical terms, spell allergens and reaction types, and offer examples. Avoid medical jargon, and when necessary, explain terms in plain language. Conclude naturally: Once the patient's question is satisfactorily answered, end the interaction gracefully, signaling the conclusion of assistance. Commands for the LLM: For every patient query, quickly identify and clarify the allergen and reaction type. Keep responses to 1-2 sentences, ensuring they are direct and easily understandable. After providing the needed information, close the conversation with a polite sign-off, indicating the patient has enough information to proceed.Your goal is to empower patients with the knowledge they need in the most efficient and clear manner possible."
                    )
        ) {}
//        self._pageTitle = pageTitle
//        self._initialQuestion = initialQuestion
//        self._prompt = prompt
    }
}


#Preview {
    LLMAssistantView(presentingAccount: .constant(false))
        .previewWith {
            LLMRunner {
                LLMOpenAIRunnerSetupTask()
            }
        }
}
