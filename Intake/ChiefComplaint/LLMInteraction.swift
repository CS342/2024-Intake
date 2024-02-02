//
//  LLMInteraction.swift
//  Intake
//
//  Created by Nick Riedman on 1/25/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SwiftUI

struct LLMInteraction: View {
    @Binding var presentingAccount: Bool
    @Environment(LLMRunner.self) var runner: LLMRunner
    
    @State var responseText: String
    @State var showOnboarding = true
    @State var model: LLM = LLMOpenAI(
        parameters: .init(
            modelType: .gpt3_5Turbo,
            systemPrompt: """
                You are acting as an intake person at a clinic and need to work with\
                the patient to help clarify their chief complaint into a concise,\
                specific complaint which includes elements of laterality if\
                appropriate, as well as severity and duration.\
                
                Please use everyday layman terms and avoid using complex medical terminology.\
                Only ask one question or prompt at a time, and keep your responses brief (one to two short sentences).
            """
        )
    )

    func executePrompt(prompt: String) async {
        // Execute the query on the runner, returning a stream of outputs
        let stream = try? await runner(with: model).generate(prompt: prompt)
        
        if let unwrappedStream = stream {
            do {
                for try await token in unwrappedStream {
                    responseText.append(token)
                }
            } catch {
                // Handle any errors that occurred during the asynchronous operation
                print("Error: \(error)")
            }
        }
    }
    
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
    LLMInteraction(presentingAccount: .constant(true), responseText: "Test")
        .previewWith {
            LLMRunner {
                LLMOpenAIRunnerSetupTask()
            }
        }
}
