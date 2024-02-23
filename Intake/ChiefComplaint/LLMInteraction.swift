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

struct SkipButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Skip")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(8) // Add padding for better appearance
                .background(Color.white) // Set background color to white
                .cornerRadius(8) // Round the corners
        }
        .buttonStyle(PlainButtonStyle()) // Remove button border
    }
}

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
    
    @State var showOnboarding = true
    @State var greeting = true
    @State var stringBox: StringBox
    @State var showSheet = false
    
    @State var model: LLM
    
    var body: some View {
        LLMChatView(
            model: model,
//            exportFormat: .nil
        )
        .navigationTitle("Chief Complaint")
        .navigationBarItems(trailing: SkipButton {
            self.showSheet = true
        })
        
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
    
    init(presentingAccount: Binding<Bool>) {
        // swiftlint:disable closure_end_indentation
        self._presentingAccount = presentingAccount
        let stringBoxTemp = StringBox()
        self.stringBox = stringBoxTemp
        self.model = LLMOpenAI(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: """
                        Pretend you are a nurse. Your job is to gather information about the medical concern of a patient.\
                        Your job is to provide a summary of the patient’s chief medical complaint to the doctor so that the doctor\
                        has all of the information they need to begin the appointment. Ask questions specific to the concern of the\
                        patient in order to help clarify their chief complaint into a concise, specific concern. Ask the patient to\
                        elaborate a little bit if you feel that they are not providing sufficient information. You should always ask about\
                        severity and onset, and if relevant to the specific condition, you might specific questions about the location,\
                        laterality, triggers, character, timing, description, progression, and associated symptoms unique to the complaint.\
                        Ask with empathy.\
                        Headache:\
                        Onset: When did the headache start? Location: Where is the pain located? Duration: How long does each headache episode last?\
                        Severity: On a scale of 1 to 10, how would you rate the pain? Triggers: Are there any specific triggers\
                        that seem to bring on the headache? Associated Symptoms: Do you experience nausea, vomiting, sensitivity to light or sound?\
                        Abdominal Pain:\
                        Location: Where is the pain located abdomen? Character: How would you describe the pain (e.g., sharp, dull, cramping)?\
                        Severity: On a scale of 1 to 10, how severe is the pain? Timing: Does the pain come and go, or is it constant?\
                        Associated Symptoms: Any nausea, vomiting, or other changes in your bowl?\
                        Fever:\
                        Temperature: What is your current temperature?\
                        Onset: When did the fever start?\
                        Duration: How long have you had the fever?\
                        Associated Symptoms: Any chills, sweating, body aches?\
                        Recent Travel or Exposure: Have you traveled recently?\
                        Have you been around anyone who was sick?
                        Rash:\
                        Onset: When did the rash first appear? Location: Where is the rash located on your body? Description: How would you\
                        describe the rash (e.g., raised, itchy, red)? Progression: Has the rash changed in appearance since it first appeared?\
                        Associated Symptoms: Any fever, itching, pain?\
                        Joint Pain:\
                        Location: Which joints are affected? Onset: When did the joint pain start? Character: How would you describe the pain\
                        (e.g., sharp, dull, achy)? Timing: Does the pain occur at specific times of the day or with certain activities?\
                        Associated Symptoms: Any swelling, redness, stiffness?\
                        Fatigue: Onset: When did you start feeling fatigued? Duration: How long have you been experiencing fatigue?\
                        Severity: On a scale of 1 to 10, how would you rate your fatigue? Triggers: Is there anything that seems to\
                        make your fatigue better or worse? Associated Symptoms: Any changes in appetite, sleep disturbances?\
                        As you can see by the examples, you should ask questions specific to the patient's symptoms. If relevant, you should\
                        ask follow-up questions to the patient's responses in order to gather more information if you feel it is needed. \
                        Please use everyday layman terms and avoid using complex medical terminology.\
                        Only ask one question or prompt at a time, and keep your questions brief (one to two short sentences).
                    """
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
