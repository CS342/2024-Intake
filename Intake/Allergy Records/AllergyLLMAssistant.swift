//
//  AllergyLLMAssistant.swift
//  Intake
//
//  Created by Akash Gupta on 3/4/24.
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
    struct AddAllergy: LLMFunction {
        @Environment(DataStore.self) private var data
        static let name: String = "add_allergy"
        static let description: String = """
                    If the user wants to add an allergy that is not currently \
                    in their list of allergies, help them figure out the name \
                    of allergy and associated reaction and add them to the list
                    """

        @Parameter(description: "This is the allergy that the user wants to add") var allergy: String
        @Parameter(description: "These are the corresponding reactions that the user gets when they have allergy") var reactions: [String]


        func execute() async throws -> String? {
            var reactionsAdding: [ReactionItem] = []
            for reaction in reactions {
                reactionsAdding.append(ReactionItem(reaction: reaction))
            }
            data.allergyData.append(AllergyItem(allergy: allergy, reaction: reactionsAdding))
            return "We have added /(allergy)"
        }
    }
    
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
            if greeting {
                let assistantMessage = ChatEntity(role: .assistant, content: "Do you have any questions about your allergies?")
                session.context.insert(assistantMessage, at: 0)
            }
            greeting = false
            if let currentallergy = getCurrentPatientAllergy(allergyList: data.allergyData) {
                session.context.append(
                    systemMessage: currentallergy
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
                    Pretend you are a nurse. Your job is to answer information about the patient's allergies.\
                    Please use everyday layman terms and avoid using complex medical terminology.\
                    Only ask one question or prompt at a time, and keep your questions brief (one to two short sentences).
                  """
            )
          ) {
              AddAllergy()
            }
        )
      }
    }


//#Preview {
//  LLMInteraction(presentingAccount: .constant(false))
//    .previewWith {
//      LLMRunner {
//        LLMOpenAIPlatform()
//      }
//    }
//}
