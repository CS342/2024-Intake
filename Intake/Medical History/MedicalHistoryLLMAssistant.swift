//
//  MedicalHistoryLLMAssistant.swift
//  Intake
//
//  Created by Kate Callon on 3/4/24.
//

import Foundation
import SpeziChat
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SwiftUI

func getCurrentPatientMedicalHistory(medHistoryList: [MedicalHistoryItem]) -> String? {
    var medHistoryDetails = "The patient has had several conditions in their medical history described in the following setneces."
    
    for medHistory in medHistoryList{
        let medHistoryName = medHistory.condition
        let active = medHistory.active
        if active{
            medHistoryDetails += "The patient has the condition \(medHistoryName) and it is currently an active condition.\n"
        }
        else{
            medHistoryDetails += "The patient has the condition \(medHistoryName) and it is currently an inactive condition.\n"
        }
        
    }
    
    return medHistoryDetails.isEmpty ? nil : medHistoryDetails
                
    
}



struct MedicalHistoryLLMAssistant: View {
    
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
        .navigationTitle("Medical History Assistant")
        
        .sheet(isPresented: $showOnboarding) {
            LLMOnboardingView(showOnboarding: $showOnboarding)
        }
        
        .onAppear {
            if let currentMedHistory = getCurrentPatientMedicalHistory(medHistoryList: data.conditionData){
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
        
    }

    init(presentingAccount: Binding<Bool>) {    // swiftlint:disable:this function_body_length
        self._presentingAccount = presentingAccount
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: """
                        Pretend you are a nurse. Your job is to answer information about the patient's medical history.\
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
