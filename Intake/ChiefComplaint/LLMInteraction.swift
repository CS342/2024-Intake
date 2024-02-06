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

import SpeziChat
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SwiftUI

struct LLMInteraction: View {
    @Observable
    class StringBox: Equatable {
        var llmResponseSummary: String
        
        init() {
            self.llmResponseSummary = ""
        }
        
        static func == (lhs: LLMInteraction.StringBox, rhs: LLMInteraction.StringBox) -> Bool {
            lhs.llmResponseSummary == rhs.llmResponseSummary
        }
    }
    
    struct SummarizeFunction: LLMFunction {
        static let name: String = "summarize_complaint"
        static let description: String = """
                    When there is enough information to give to the doctor,\
                    summarize the conversation into a concise Chief Complaint.
                    """
        @Parameter(description: "The primary medical concern that the patient is experiencing.") var medicalConcern: String
        
        @Parameter(description: "The severity of the primary medical concern.") var severity: String
        
        @Parameter(description: "The duration of the primary medical concern.") var duration: String
        
        static let desc: String = """
            Extra important information relevant to the primary\
            medical concern that the doctor should be aware of.
            """
        @Parameter(description: desc) var supplementaryInfo: String
        
        let stringBox: StringBox
        
        init(stringBox: StringBox) {
            self.stringBox = stringBox
        }
        
        func execute() async throws -> String? {
            let summary = """
            Here is the summary that will be provided to your doctor:\n
                Primary concern: \(medicalConcern)\n
                Severity: \(severity)\n
                Duration: \(duration)\n
                Extra Info: \(supplementaryInfo)\n
            """
            
            self.stringBox.llmResponseSummary = summary
            
            return nil
        }
    }
    
    @Binding var presentingAccount: Bool
    @Environment(LLMRunner.self) var runner: LLMRunner
    
    @State var showOnboarding = true
    @State var greeting = true
    @State var stringBox: StringBox
    @State var showSheet = false
    
    @State var model: LLM
    
    var body: some View {
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
        .onAppear {
            if greeting {
                let assistantMessage = ChatEntity(role: .assistant, content: "Hello! What brings you to the doctor's office?")
                model.context.insert(assistantMessage, at: 0)
            }
            greeting = false
        }
        .onChange(of: self.stringBox.llmResponseSummary) { _, _ in
            self.showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            SummaryView(chiefComplaint: self.stringBox.llmResponseSummary)
        }
    }
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
        let stringBoxTemp = StringBox()
        self.stringBox = stringBoxTemp
        self.model = LLMOpenAI(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: """
                        You are acting as an intake person at a clinic and need to work with\
                        the patient to help clarify their chief complaint into a concise,\
                        specific complaint.
                    
                        You should always ask about severity and duration if the patient does not include this information.
                        
                        Additionally, help guide the patient into providing information specific to the condition that the define.\
                        For example, if the patient is experiencing leg pain, you should prompt them to be more\
                        specific about laterality and location. You should also ask if the pain is dull or sharp,\
                        and encourage them to rate their pain on a scale of 1 to 10. For a cough, for example, you\
                        should inquire whether the cough is wet or dry, as well as any other characteristics of the\
                        cough that might allow a doctor to rule out diagnoses.
                        
                        Please use everyday layman terms and avoid using complex medical terminology.\
                        Only ask one question or prompt at a time, and keep your responses brief (one to two short sentences).
                    """
                )
            ) {
                SummarizeFunction(stringBox: stringBoxTemp)
            }
    }
}

#Preview {
    LLMInteraction(presentingAccount: .constant(false))
        .previewWith {
            LLMRunner {
                LLMOpenAIRunnerSetupTask()
            }
        }
}
