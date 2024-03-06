//
//  AllergyLLMAssistant.swift
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

func getCurrentPatientAllergy(allergyList: [AllergyItem]) -> String? {
    var allergyDetails = "The patient has several allergies described in the next sentences."
    
    for allergy in allergyList {
        let allergyName = allergy.allergy
        if let allergyReaction = allergy.reaction.first?.reaction {
            allergyDetails += "The patient has allergy \(allergyName) with the reaction \(allergyReaction).\n"
        } else {
            allergyDetails += "The patient has allergy \(allergyName).\n"
        }
    }
    
    return allergyDetails.isEmpty ? nil : allergyDetails
}

struct AllergyLLMAssistant: View {
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
        .navigationTitle("Allergy Assistant")
        
        .sheet(isPresented: $showOnboarding) {
            LLMOnboardingView(showOnboarding: $showOnboarding)
        }
        
        .onAppear {
            if let currentallergy = getCurrentPatientAllergy(allergyList: data.allergyData) {
                session.context.append(
                                    systemMessage: currentallergy
                                )
            }
            
            if greeting {
                let assistantMessage = ChatEntity(role: .assistant, content: "Do you have any questions about your allergies?")
                session.context.insert(assistantMessage, at: 0)
            }
            greeting = false
        }
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: """
                        Pretend you are a nurse. Your job is to answer information about the patient's allergies.\
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
