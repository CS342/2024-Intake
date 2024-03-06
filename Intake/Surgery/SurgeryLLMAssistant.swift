//
//  SurgeryLLMAssistant.swift
//  Intake
//
//  Created by Kate Callon on 3/4/24.
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

func getCurrentPatientSurgery(surgeryList: [SurgeryItem]) -> String? {
    var surgeryDetails = "The patient has had several surgeries."
    
    for surgery in surgeryList {
        let surgeryName = surgery.surgeryName
        let surgeryDate = surgery.date
        surgeryDetails += "The patient had surgery \(surgeryName) on \(String(describing: surgeryDate)).\n"
    }
    
    return surgeryDetails.isEmpty ? nil : surgeryDetails
}

struct SurgeryLLMAssistant: View {
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    
    @Binding var presentingAccount: Bool
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession

    @State var showOnboarding = true
    @State var greeting = true
    
    var body: some View {
        @Bindable var data = data
        
        LLMChatView(
            session: $session
        )
        .navigationTitle("Surgery Assistant")
        
        .sheet(isPresented: $showOnboarding) {
            LLMOnboardingView(showOnboarding: $showOnboarding)
        }
        
        .onAppear {
            if greeting {
                let assistantMessage = ChatEntity(role: .assistant, content: "Do you have any questions about your medications?")
                session.context.insert(assistantMessage, at: 0)
            }
            greeting = false
            
            if let currentSurgery = getCurrentPatientSurgery(surgeryList: data.surgeries) {
                session.context.append(
                                    systemMessage: currentSurgery
                                )
            }
        }
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: """
                        Pretend you are a nurse. Your job is to answer information about the patient's surgery.\
                        Please use everyday layman terms and avoid using complex medical terminology.\
                        Only ask one question or prompt at a time, and keep your questions brief (one to two short sentences).
                    """
                )
            ) {
            }
        )
    }
}

#Preview {
    LLMInteraction(presentingAccount: .constant(false))
        .previewWith {
            LLMRunner {
                LLMOpenAIPlatform()
            }
        }
}
