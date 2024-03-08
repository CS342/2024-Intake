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

@Observable
class SurgeryItemBox: Equatable {
    var surgeryItem: SurgeryItem?

    init() {}

    static func == (lhs: SurgeryItemBox, rhs: SurgeryItemBox) -> Bool {
        lhs.surgeryItem == rhs.surgeryItem
    }
}

func getCurrentPatientSurgery(surgeryList: [SurgeryItem]) -> String? {
    var surgeryDetails = "The patient has had several surgeries."
    
    for surgery in surgeryList {
        let surgeryName = surgery.surgeryName
        let surgeryDate = surgery.date
        surgeryDetails += "The patient had surgery \(surgeryName) on \(String(describing: surgeryDate)).\n"
    }
    
    return surgeryDetails.isEmpty ? nil : surgeryDetails
}

struct UpdateSurgeryFunction: LLMFunction {
    static let name: String = "update_surgeries"
    static let description: String = """
                If the patient wants to add a surgery and they've given you the surgery name and date, \
                call the update_surgeries function to add it.
                """
    
    @Parameter(description: "The surgery the patient wants to create.") var surgeryName: String
    @Parameter(description: "The surgery date the patient wants to create.") var surgeryDate: String
    
    let surgeryItemBox: SurgeryItemBox

    init(surgeryItemBox: SurgeryItemBox) {
        self.surgeryItemBox = surgeryItemBox
    }
    

    func execute() async throws -> String? {
        let updatedSurgery = SurgeryItem(surgeryName: surgeryName, date: surgeryDate)
        surgeryItemBox.surgeryItem = updatedSurgery
        return nil
    }
}

struct SurgeryLLMAssistant: View {
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    
    @Binding var presentingAccount: Bool
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession

    @State var showOnboarding = true
    @State var greeting = true
    
    @State var surgeryItemBox: SurgeryItemBox
    
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
            print("surgerybox", surgeryItemBox)
            if greeting {
                let assistantMessage = ChatEntity(role: .assistant, content: "Do you have any questions about your surgeries?")
                session.context.insert(assistantMessage, at: 0)
            }
            greeting = false
            
            if let currentSurgery = getCurrentPatientSurgery(surgeryList: data.surgeries) {
                session.context.append(
                                    systemMessage: currentSurgery
                                )
            }
        }
        .onChange(of: surgeryItemBox.surgeryItem) { _, newValue in
            if let surgeryItem = newValue {
                data.surgeries.append(surgeryItem)
            }
        }
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
        let temporarySurgeryItemBox = SurgeryItemBox()
        self.surgeryItemBox = temporarySurgeryItemBox
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: """
                        Pretend you are a nurse. Your job is to answer information about the patient's surgery.\
                        You have the ability to add a surgery if the patient tells you to by calling the update_surgeries function.\
                        Only call the update_surgeries function if the patient has given you both the name and the date of the surgery.\
                        You do not have the ability to delete a surgery from the patient's list.\
                        Please use everyday layman terms and avoid using complex medical terminology.\
                        Only ask one question or prompt at a time, and keep your questions brief (one to two short sentences).
                    """
                )
            ) {
                UpdateSurgeryFunction(surgeryItemBox: temporarySurgeryItemBox)
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