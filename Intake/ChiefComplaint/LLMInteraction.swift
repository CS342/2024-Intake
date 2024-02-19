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
import SpeziFHIR
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
                    summarize the conversation into a concise Chief Complaint.\
                    Then call the summerize_complaint function.
                    """

        
        @Parameter(description: "A summary of the patient's primary concern.") var patientSummary: String
        
        let stringBox: StringBox
        
        init(stringBox: StringBox) {
            self.stringBox = stringBox
        }
        
        func execute() async throws -> String? {
            let summary = patientSummary
            self.stringBox.llmResponseSummary = summary
            return nil
        }
    }
    
    @Binding var presentingAccount: Bool
    @Environment(LLMRunner.self) var runner: LLMRunner
    @Environment(FHIRStore.self) private var fhirStore
    
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
        .toolbar {  // Is this doing anything except causing problems?
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
            SummaryView(chiefComplaint: self.stringBox.llmResponseSummary, isPresented: $showSheet)
        }
    }

// how do i get this json decoded so that i can iterate through it?
// specifically want to use mock patient for testing and then use fhirstore later
// then how do i get patient summary from llmonfhir from it?! .jsonDescription is used in LLMonFHIR

    
    
    
//    private func prepareSystemPrompt() {
//        if chat.isEmpty {
//            chat = [
//                Chat(
//                    role: .system,
//                    content: FHIRPrompt.interpretMultipleResources.prompt
//                )
//            ]
//        }
//        if let patient = fhirStore.patient {
//            print(patient.jsonDescrption)
////            chat.append(
////                Chat(
////                    role: .system,
////                    content: patient.jsonDescription
////
////                )
//            )
//        }
//    }
    
//    var patient: FHIRResource? {
//        let appBundlePath = Bundle.main.bundlePath
//        if let bundle = Bundle(url: URL(fileURLWithPath: "[appBundlePath]/Resources/MockPatients/Beatris270_Bogan287_5b3645de-a2d0-d016-0839-bab3757c4c58.json")) {
//            var fileContent = String?
//            do {
//                fileContent = try String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8)
//            } catch {
//                print("Error reading file: \(error)")
//            }
//    
//    func getPatientHistorySummary(){
//        if let patient = FHIRStore.patient{
//            let patientDescription = patient.jsonDescription
//        }
//    }
    
    init(presentingAccount: Binding<Bool>) {
        // swiftlint:disable closure_end_indentation
        self._presentingAccount = presentingAccount
        let stringBoxTemp = StringBox()
        self.stringBox = stringBoxTemp
        self.model = LLMOpenAI(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: "CHIEF_COMPLAINT_SYSTEM_PROMPT"
                )
            ) {
                SummarizeFunction(stringBox: stringBoxTemp)
            }
        // swiftlint:enable closure_end_indentation
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
