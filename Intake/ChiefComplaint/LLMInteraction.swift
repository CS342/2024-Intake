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
    @State private var chiefComplaint: String? = "blah blah blah"
    
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
        
        @Binding var chiefComplaint: String
        
        func execute() async throws -> String? {
            let summary = """
            Here is the summary that will be provided to your doctor:\n
                Primary concern: \(medicalConcern)\n
                Severity: \(severity)\n
                Duration: \(duration)\n
                Extra Info: \(supplementaryInfo)\n
            """
            chiefComplaint = summary
            return summary
        }
    }
    
    @State private var shouldNavigateToSummaryView = true
    @Binding var presentingAccount: Bool
    @Environment(LLMRunner.self) var runner: LLMRunner
    
    @State var responseText: String
    @State var showOnboarding = true
//    @State var charSystemPrompt: self.ChatEntity
//    @State var chatRole: self.ChatEntity
    
//    @State var model: LLM
    
//    init() {
//        model = LLMOpenAI(
//            parameters: .init(
//                modelType: .gpt3_5Turbo,
//                systemPrompt: """
//                    You are acting as an intake person at a clinic and need to work with\
//                    the patient to help clarify their chief complaint into a concise,\
//                    specific complaint.
//                
//                    You should always ask about severity and duration if the patient does not include this information.
//                
//                    Additionally, help guide the patient into providing information specific to the condition that the define.\
//                    For example, if the patient is experiencing leg pain, you should prompt them to be more\
//                    specific about laterality and location. You should also ask if the pain is dull or sharp,\
//                    and encourage them to rate their pain on a scale of 1 to 10. For a cough, for example, you\
//                    should inquire whether the cough is wet or dry, as well as any other characteristics of the\
//                    cough that might allow a doctor to rule out diagnoses.
//                
//                    Please use everyday layman terms and avoid using complex medical terminology.\
//                    Only ask one question or prompt at a time, and keep your responses brief (one to two short sentences).
//                """
//            )
//        )
//        $model.function = SummarizeFunction(ChiefComplaint: $ChiefComplaint)
//    }
    
    
    @State var model: LLM = LLMOpenAI(
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
//        SummarizeFunction(ChiefComplaint: $ChiefComplaint)
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
            .onAppear{
                model.context.append()
            }
            // greeting
//            .onAppear {
//                Task {
//                    do {
//                        let stream = try await runner(with: model).generate(prompt: """
//                                        Hello! I am a patient coming in to see the doctor and would like\
//                                        to discuss the reason for my visit.
//                                    """)
//                        var isFirstToken = true
//                        for try await token in stream {
//                            if isFirstToken {
//                                isFirstToken = false
//                                continue }
//                            model.context.append(assistantOutput: token)}}}}
//            
            
            
            
            
            // navigation to summary view after chat
            .onChange(of: chiefComplaint) { _, newChiefComplaint in
                if let newChiefComplaint = newChiefComplaint {
                    shouldNavigateToSummaryView = true}}
            .background(
                NavigationLink(
                    destination: SummaryView(chiefComplaint: chiefComplaint ?? "error"),
                    isActive: $shouldNavigateToSummaryView
                ) { EmptyView() }
                .isDetailLink(false)
                .navigationDestination(isPresented: $shouldNavigateToSummaryView) {
                    EmptyView() })}}}


#Preview {
    LLMInteraction(presentingAccount: .constant(true), responseText: "Test")
        .previewWith {
            LLMRunner {
                LLMOpenAIRunnerSetupTask()
            }
        }
}

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
    @State private var chiefComplaint: String? = "blah blah blah"
    
    struct SummarizeFunction: LLMFunction {
        static let name: String = "summarize_complaint"
        static let description: String = """
                    When there is enough information to give to the doctor,\
                    summarize the conversation into a concise Chief Complaint.
                    """
        
        @Parameter(description: "The primary medical concern that the patient is experiencing.") var medicalConcern: String
        
        @Parameter(description: "The severity of the primary medical concern.") var severity: String
        
        @Parameter(description: "The duration of the primary medical concern.") var duration: String
        
        @Parameter(description: "Extra important information relevant to the primary medical concern that the doctor should be aware of.") var supplementaryInfo: String
        
        @Binding var chiefComplaint: String
        
        func execute() async throws -> String? {
            let summary = """
            Here is the summary that will be provided to your doctor:\n
                Primary concern: \(medicalConcern)\n
                Severity: \(severity)\n
                Duration: \(duration)\n
                Extra Info: \(supplementaryInfo)\n
            """
            chiefComplaint = summary
            return summary
        }
    }
    
    @State private var shouldNavigateToSummaryView = true
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
        //        SummarizeFunction(ChiefComplaint: $ChiefComplaint)
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
            .onAppear {
                Task {
                    do {
                        let stream = try await runner(with: model).generate(prompt: """
                                        Hello! I am a patient coming in to see the doctor and would like\
                                        to discuss the reason for my visit.
                                    """)
                        var isFirstToken = true
                        for try await token in stream {
                            if isFirstToken {
                                isFirstToken = false
                                continue }
                            model.context.append(assistantOutput: token)
                        }
                    }
                }
            }
            .onChange(of: chiefComplaint) { _, newChiefComplaint in
                if let newChiefComplaint = newChiefComplaint {
                    shouldNavigateToSummaryView = true
                }
            }
            .background(
                NavigationLink(
                    destination: SummaryView(chiefComplaint: chiefComplaint ?? "error"),
                    isActive: $shouldNavigateToSummaryView
                ) {
                    EmptyView()
                }
                    .isDetailLink(false)
                    .navigationDestination(isPresented: $shouldNavigateToSummaryView) {
                        EmptyView()
                    }
            )
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
