//
//  LLMAssistantView.swift
//  Intake
//
//  Created by Akash Gupta on 2/18/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziChat
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SwiftUI

// My head hurts. 10/10 pain. Sharp. Top of head. Hurts for a week. No triggers. Nothing makes it better or worse. No further information that I have
struct LLMAssistantView: View {
    @Binding var presentingAccount: Bool
    @State var showOnboarding = true
    @State var greeting = true
    @Binding var pageTitle: String
    @Binding var initialQuestion: String
    @Binding var prompt: String
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession

    var body: some View {
        NavigationView {
            LLMChatView(
                session: $session
            )
            .sheet(isPresented: $showOnboarding) {
                LLMOnboardingView(showOnboarding: $showOnboarding)
            }
            .navigationTitle(pageTitle)
            .toolbar {  // Is this doing anything except causing problems?
                if AccountButton.shouldDisplay {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .onAppear {
                if greeting {
                    let assistantMessage = ChatEntity(role: .assistant, content: initialQuestion)
                    session.context.insert(assistantMessage, at: 0)
                }
                greeting = false
            }
        }
    }

    init(presentingAccount: Binding<Bool>, pageTitle: Binding<String>, initialQuestion: Binding<String>, prompt: Binding<String>) {
        self._presentingAccount = presentingAccount
        self._session = LLMSessionProvider(
                schema: LLMOpenAISchema(
                    parameters: .init(
                        modelType: .gpt3_5Turbo,
                        systemPrompt: prompt.wrappedValue
                    )
                ) {}
            )
        self._pageTitle = pageTitle
        self._initialQuestion = initialQuestion
        self._prompt = prompt
    }
}

#Preview {
    LLMAssistantView(
        presentingAccount: .constant(false),
        pageTitle: .constant("Allergy Assistant"),
        initialQuestion: .constant("Do you have any questions about your allergies"),
        prompt: .constant("Pretend you are a nurse. Your job is to help the patient understand what allergies they have.")
    )
        .previewWith {
            LLMRunner {
                LLMOpenAIPlatform()
            }
        }
}