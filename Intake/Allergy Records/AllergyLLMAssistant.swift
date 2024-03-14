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

@Observable
class AllergyItemBox: Equatable {
    var allergyItem: AllergyItem?

    init() {}

    static func == (lhs: AllergyItemBox, rhs: AllergyItemBox) -> Bool {
        lhs.allergyItem == rhs.allergyItem
    }
}

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

struct UpdateAllergyFunction: LLMFunction {
    static let name: String = "update_allergies"
    static let description: String = """
                If the patient wants to add an allergy and they've given you the allergy name and the reaction they have to the allergy, \
                call the update_allergies function to add it.
                """
    
    @Parameter(description: "The allergy name the patient wants to create.") var allergyName: String
    @Parameter(description: "The reaction of the allergy the patient wants to create.") var allergyReaction: String
    
    let allergyItemBox: AllergyItemBox

    init(allergyItemBox: AllergyItemBox) {
        self.allergyItemBox = allergyItemBox
    }
    

    func execute() async throws -> String? {
        let updatedAllergy = AllergyItem(allergy: allergyName, reaction: [ReactionItem(reaction: allergyReaction)])
        allergyItemBox.allergyItem = updatedAllergy
        return nil
    }
}

// The AllergyLLMAssistant allows the user to ask the chat questions about their current allergies and add new allergies to their data.
struct AllergyLLMAssistant: View {
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    
    @Binding var presentingAccount: Bool
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession

    @State var showOnboarding = true
    @State var greeting = true
    
    @State var allergyItemBox: AllergyItemBox
    
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
        .onChange(of: allergyItemBox.allergyItem) { _, newValue in
            if let allergyItem = newValue {
                data.allergyData.append(allergyItem)
            }
        }
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
        let temporaryAllergyItemBox = AllergyItemBox()
        self.allergyItemBox = temporaryAllergyItemBox
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: """
                        Pretend you are a nurse. Your job is to answer information about the patient's allergies.\
                        You have the ability to add a allergy if the patient tells you to by calling the update_allergies function.\
                        Only call the update_allergies function if the patient has given you both the allergy name and the allergy reaction type.\
                        You do not have the ability to delete an allergy from the patient's list.\
                        Please use everyday layman terms and avoid using complex medical terminology.\
                        Only ask one question or prompt at a time, and keep your questions brief (one to two short sentences).
                    """
                )
            ) {
                UpdateAllergyFunction(allergyItemBox: temporaryAllergyItemBox)
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
