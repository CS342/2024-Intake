//
//  MedicationLLMAssistant.swift
//  Intake
//
//  Created by Kate Callon on 3/2/24.
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

func getCurrentPatientMedications(medicationList: Set<IntakeMedicationInstance>) -> String? {
    var medicationDetails = "The patient is currently taking several medications:"
    print(medicationList)
    for medication in medicationList {
        let medName = medication.type.localizedDescription
        let dose = medication.dosage.localizedDescription
        let frequency = medication.schedule.frequency
        medicationDetails += "The patient is taking medication \(medName), the dose is \(dose), and the frequency is \(frequency).\n"
    }
    
    return medicationDetails.isEmpty ? nil : medicationDetails
}

struct MedicationLLMAssistant: View {
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
        .navigationTitle("Medications Assistant")
        
        .sheet(isPresented: $showOnboarding) {
            LLMOnboardingView(showOnboarding: $showOnboarding)
        }
        
        .onAppear {
            if greeting {
                let assistantMessage = ChatEntity(role: .assistant, content: "Do you have any questions about your medications?")
                session.context.insert(assistantMessage, at: 0)
            }
            greeting = false
            
            if let currentMed = getCurrentPatientMedications(medicationList: data.medicationData) {
                session.context.append(
                                    systemMessage: currentMed
                                )
            }
        }
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt4,
                    systemPrompt: """
                        Pretend you are a nurse. Your job is to answer information about the patient's medications.\
                        You do not have the ability to add or delete medications, so please tell the patient that.\
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
