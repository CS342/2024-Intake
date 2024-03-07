//
//  MedicalHistoryLLMAssistant.swift
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

@Observable
class MedicalHistoryItemBox: Equatable {
    var medicalHistoryItem: MedicalHistoryItem?

    init() {}

    static func == (lhs: MedicalHistoryItemBox, rhs: MedicalHistoryItemBox) -> Bool {
        lhs.medicalHistoryItem == rhs.medicalHistoryItem
    }
}


func getCurrentPatientMedicalHistory(medHistoryList: [MedicalHistoryItem]) -> String? {
    var medHistoryDetails = "The patient has had several conditions in their medical history described in the following sentences."
    
    for medHistory in medHistoryList {
        let medHistoryName = medHistory.condition
        let active = medHistory.active
        if active {
            medHistoryDetails += "The patient has the condition \(medHistoryName) and it is currently an active condition.\n"
        } else {
            medHistoryDetails += "The patient has the condition \(medHistoryName) and it is currently an inactive condition.\n"
        }
    }
    
    return medHistoryDetails.isEmpty ? nil : medHistoryDetails
}

struct UpdateMedicalHistoryFunction: LLMFunction {
    static let name: String = "update_medical_history"
    static let description: String = """
                If the patient wants to add to their medical history and they've given you the condition name\
                and if it's an active or inactive condition\
                call the update_medical_history function to add it.
                """
    
    @Parameter(description: "The medical history condition name the patient wants to create.") var condition: String
    @Parameter(description: "If the condition is active or inactive.") var active: String
    
    let medicalHistoryItemBox: MedicalHistoryItemBox

    init(medicalHistoryItemBox: MedicalHistoryItemBox) {
        self.medicalHistoryItemBox = medicalHistoryItemBox
    }
    

    func execute() async throws -> String? {
        var activeBool: Bool
        if active == "active" {
            activeBool = true
        } else {
            activeBool = false
        }
        let updatedMedicalHistory = MedicalHistoryItem(condition: condition, active: activeBool)
        medicalHistoryItemBox.medicalHistoryItem = updatedMedicalHistory
        return nil
    }
}

struct MedicalHistoryLLMAssistant: View {
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    
    @Binding var presentingAccount: Bool
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession

    @State var showOnboarding = true
    @State var greeting = true
    
    @State var medicalHistoryItemBox: MedicalHistoryItemBox
    
    var body: some View {
        @Bindable var data = data
        
        LLMChatView(
            session: $session
        )
        .navigationTitle("Medical History Assistant")
        
        .sheet(isPresented: $showOnboarding) {
            LLMOnboardingView(showOnboarding: $showOnboarding)
        }
        
        .onAppear {
            if let currentMedHistory = getCurrentPatientMedicalHistory(medHistoryList: data.conditionData) {
                session.context.append(
                                    systemMessage: currentMedHistory
                                )
            }
            
            if greeting {
                let assistantMessage = ChatEntity(role: .assistant, content: "Do you have any questions about your medical history?")
                session.context.insert(assistantMessage, at: 0)
            }
            greeting = false
        }
        .onChange(of: medicalHistoryItemBox.medicalHistoryItem) { _, newValue in
            if let medicalHistoryItem = newValue {
                data.conditionData.append(medicalHistoryItem)
            }
        }
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
        let temporaryMedicalHistoryItemBox = MedicalHistoryItemBox()
        self.medicalHistoryItemBox = temporaryMedicalHistoryItemBox
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: """
                        Pretend you are a nurse. Your job is to answer information about the patient's medical history.\
                        You have the ability to add a medical history condition by calling the update_medical_history function.\
                        Only call the update_medical_history function if you know both the condition name and if it's active or inactive.\
                        You do not have the ability to delete a medical history from the patient's list.\
                        Please use everyday layman terms and avoid using complex medical terminology.\
                        Only ask one question or prompt at a time, and keep your questions brief (one to two short sentences).
                    """
                )
            ) {
                UpdateMedicalHistoryFunction(medicalHistoryItemBox: temporaryMedicalHistoryItemBox)
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
