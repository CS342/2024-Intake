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

import Foundation
import SpeziChat
import SpeziFHIR
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SwiftUI

func calculateAge(from dobString: String, with format: String = "yyyy-MM-dd") -> String {
    if dobString.isEmpty {
        return ""
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    
    guard let birthDate = dateFormatter.date(from: dobString) else {
        return "Invalid date format or date string."
    }
    
    let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
    if let age = ageComponents.year {
        return "\(age)"
    } else {
        return "Could not calculate age"
    }
}

func getValue(forKey key: String, from jsonString: String) -> String? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Cannot create Data from JSON string")
        return nil
    }
    
    do {
        if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            if key == "name" {
                if let nameArray = dictionary[key] as? [[String: Any]], !nameArray.isEmpty {
                    let nameDict = nameArray[0] // Accessing the first name object
                    if let family = nameDict["family"] as? String,
                       let givenArray = nameDict["given"] as? [String],
                       !givenArray.isEmpty {
                        let given = givenArray.joined(separator: " ") // Assuming there might be more than one given name
                        
                        return "\(given) \(family)"
                    }
                }
            } else {
                return dictionary[key] as? String
            }
        } else {
            print("Error: JSON is not a dictionary")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }

    return nil
}

func getInfo(patient: FHIRResource, field: String) -> String {
    let jsonDescription = patient.jsonDescription

    if let infoValue = getValue(forKey: field, from: jsonDescription) {
        print("Info found: \(infoValue)")
        return infoValue
    }
    
    print("Key \(field) not found")
    return ""
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
                    summarize the conversation into a concise Chief Complaint.\
                    Then call the summerize_complaint function.
                    """
      
        static let summaryDescription = """
                A summary of the patient's primary concern. Include a sentence introducing the patient's name,\
                age, and gender, if you have access to this information.
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
    
    @Environment(LLMRunner.self) var runner: LLMRunner
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    
    @Binding var presentingAccount: Bool
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession

    @State var showOnboarding = true
    @State var greeting = true

    @State var stringBox: StringBox = .init()
    @State var showSheet = false
  
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
        
        .onAppear {
            var fullName: String = ""
            var firstName: String = ""
            var dob: String = ""
            var gender: String = ""
            if let patient = fhirStore.patient {
                fullName = getInfo(patient: patient, field: "name").filter { !$0.isNumber }
                dob = getInfo(patient: patient, field: "birthDate")
                gender = getInfo(patient: patient, field: "gender")

                let age = calculateAge(from: dob)
                let nameString = fullName.components(separatedBy: " ")
                
                data.generalData.name = fullName
                data.generalData.birthdate = dob
                data.generalData.sex = gender
                data.generalData.age = age
                
                firstName = nameString.first ?? "First Name is empty"
                print(firstName == "First Name is empty" ? "First Name is empty" : "")

                
                let systemMessage = """
                    The first name of the patient is \(String(describing: firstName)) and the patient is \(String(describing: age))\
                    years old. The patient's gender is \(String(describing: gender)) Please speak with\
                    the patient as you would a person of this age group, using as simple words as possible\
                    if the patient is young. Address them by their first name when you ask questions.
                """
                session.context.append(
                    systemMessage: systemMessage
                )
            }
            
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
  
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
        let temporaryStringBox = StringBox()
        self.stringBox = temporaryStringBox
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
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
}

#Preview {
    LLMInteraction(presentingAccount: .constant(false))
        .previewWith {
            LLMRunner {
                LLMOpenAIPlatform()
            }
        }
}
