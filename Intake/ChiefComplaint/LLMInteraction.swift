//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


import Foundation
import SpeziChat
import SpeziFHIR
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SwiftUI


/// LLMInteraction is the core functionality of Chief Complaint. It initializes the LLM, uses a robust system prompt to ensure that the questions
/// asked are specific and medically sound. It utilizes function calling to identify when enough information has been gathered about the patient
/// to be helpful to a doctor.
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
      
        static let summaryDescription = """
                A brief summary of the patient's primary concern. Include all information that would be relevant\
                for a doctor who will treat the patient.
        """
        @Parameter(description: summaryDescription) var patientSummary: String
        
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
    
    
    @State private var fullName: String = ""
    @State private var firstName: String = ""
    @State private var dob: String = ""
    @State private var gender: String = ""
    @State var showOnboarding = true
    @State var greeting = true
    @State var stringBox: StringBox = .init()
    @State var showSheet = false
    @Environment(LLMRunner.self) var runner: LLMRunner
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    
    @Environment(LLMOpenAITokenSaver.self) private var tokenSaver

    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession
    
  
    var body: some View {
        @Bindable var data = data
        
        LLMChatView(
            session: $session
        )
        .navigationTitle("Primary Concern")
        .navigationBarItems(trailing: SkipButton {
            self.showSummary()
        })
        
        .sheet(isPresented: $showOnboarding) {
            LLMOnboardingView(showOnboarding: $showOnboarding)
        }
        
        .task {
            let nameString = data.generalData.name.components(separatedBy: " ")
            if let firstNameValue = nameString.first {
                firstName = firstNameValue
            }
            let systemMessage = """
                The first name of the patient is \(String(describing: firstName)) and the patient is \(String(describing: data.generalData.age)) \
                years old. The patient's sex is \(String(describing: data.generalData.sex)) Please speak with\
                the patient as you would a person of this age group, using as simple words as possible\
                if the patient is young. Address them by their first name when you ask questions.
            """
            session.context.append(
                systemMessage: systemMessage
            )
          
            
            if greeting {
                if firstName.isEmpty {
                    session.context.append(assistantOutput: "Hello! What brings you to the doctor's office?")
                } else {
                    session.context.append(assistantOutput: "Hello \(String(describing: firstName))! What brings you to the doctor's office?")
                }
            }
            greeting = false
        }
        
        .onChange(of: self.stringBox.llmResponseSummary) { _, newComplaint in
            data.chiefComplaint = newComplaint
            self.showSummary()
        }
    }
  
    
    init() {
        let temporaryStringBox = StringBox()
        self.stringBox = temporaryStringBox
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt4,
                    systemPrompt: "CHIEF_COMPLAINT_SYSTEM_PROMPT".localized().localizedString()
                )
            ) {
                SummarizeFunction(stringBox: temporaryStringBox)
            }
        )
    }
    
    
    private func showSummary() {
        navigationPath.path.append(NavigationViews.concern)
    }
    
    private func checkToken() {
        showOnboarding = !tokenSaver.tokenPresent
    }
}


#Preview {
    LLMInteraction()
        .previewWith {
            LLMRunner {
                LLMOpenAIPlatform()
            }
        }
}
