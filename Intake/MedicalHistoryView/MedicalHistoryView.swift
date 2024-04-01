//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4
import SpeziFHIR
import SpeziLLM
import SpeziLLMOpenAI
import SwiftUI


struct MedicalHistoryView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(DataStore.self) private var data
    @Environment(LoadedWrapper.self) private var loaded
    
    @State private var showAddSheet = false
    @State private var showingChat = false
    
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession

    
    var body: some View {
        if loaded.conditionData {
            VStack {
                medicalHistoryForm
                if FeatureFlags.testCondition {
                    SubmitButton(nextView: NavigationViews.pdfs)
                        .padding()
                } else {
                    SubmitButton(nextView: NavigationViews.surgical)
                        .padding()
                }
            }
            .sheet(isPresented: $showingChat, content: chatSheetView)
        } else {
            ProgressView()
                .task {
                    do {
                        try await loadConditions()
                    } catch {
                        print("Failed to load")
                    }
                    loaded.conditionData = true
                }
        }
    }
    
    private var medicalHistoryForm: some View {
        Form {
            Section(header: Text("Please list conditions you have had")) {
                conditionEntries
                instructionText
            }
        }
        .navigationTitle("Medical History")
        .navigationBarItems(trailing: addConditionButton)
        .navigationBarItems(trailing: NavigationLink(destination: MedicalHistoryLLMAssistant()) {
            Image(systemName: "bubble")
                .accessibilityLabel("Chat with LLM Assistant")
        })
    }

    private var conditionEntries: some View {
        Group {
            @Bindable var data = data
            ForEach($data.conditionData) { $item in
                if item.active {
                    conditionEntry(item: $item)
                }
            }
            .onDelete(perform: delete)
            
            ForEach($data.conditionData) { $item in
                if !item.active {
                    conditionEntry(item: $item)
                }
            }
            .onDelete(perform: delete)
        }
    }

    private var addConditionButton: some View {
        Button(action: addConditionAction) {
            HStack {
                Image(systemName: "plus")
            }
        }
        .accessibilityLabel("add_condition")
    }

    private var instructionText: some View {
        Text("""
            *Check the box if you currently have the condition. /
            *Uncheck the box if you had the condition in the past
            """)
        .font(.caption)
        .foregroundColor(.gray)
    }
    
    
    init() {    // swiftlint:disable:this function_body_length
        let systemPrompt = """
            You are a helpful assistant that filters lists of conditions. You will be given\
            an array of strings. Each string will be the name of a condition, but we only want\
            to keep the names of relevant conditions. By relevant, we do not want to add conditions\
            that are not severe and super common such as colds and ear infections
        
            For example, if you are given the following list:
            Atopic dermatitis, Acute viral pharyngitis (disorder), Otitis media, Perennial allergic rhinitis,\
            Aortic valve stenosis (disorder), Streptococcal sore throat (disorder)
        
            you should return something like this:
            Atopic dermatitis,  Perennial allergic rhinitis, Aortic valve stenosis
        
            Another example would be if you are given the following list:
            Received higher education (finding), Body mass index 30+ - obesity (finding), Gout, Essential\
            hypertension (disorder), Chronic kidney disease stage 1 (disorder), Disorder of kidney due to\
            diabetes mellitus (disorder), Chronic kidney disease stage 2 (disorder), Microalbuminuria due\
            to type 2 diabetes mellitus (disorder), Has a criminal record (finding), Refugee (person),\
            Chronic kidney disease stage 3 (disorder), Proteinuria due to type 2 diabetes mellitus\
            (disorder), Metabolic syndrome X (disorder), Prediabetes, Limited social contact (finding),\
            Reports of violence in the environment (finding), Victim of intimate partner abuse (finding),\
            Not in labor force (finding), Social isolation (finding), Acute viral pharyngitis (disorder),\
            Unhealthy alcohol drinking behavior (finding), Anemia (disorder), Awaiting transplantation of\
            kidney (situation), Chronic kidney disease stage 4 (disorder), Unemployed (finding), Ischemic\
            heart disease (disorder), Abnormal findings diagnostic imaging heart+coronary circulat (finding),\
            History of renal transplant (situation), Viral sinusitis (disorder), Malignant neoplasm of breast\
            (disorder), Acute bronchitis (disorder)
        
            you should return something like this:
            Obesity, Gout, hypertension, Chronic kidney disease stage 1, Disorder of kidney due to\
            diabetes mellitus, Chronic kidney disease stage 2, Microalbuminuria due to type 2 diabetes mellitus,\
            Chronic kidney disease stage 3, Proteinuria due to type 2 diabetes mellitus, Metabolic syndrome X,\
            Prediabetes,  Victim of intimate partner abuse, Unhealthy alcohol drinking behavior, Anemi, Awaiting\
            transplantation of kidney, Chronic kidney disease stage 4,Ischemic heart disease, \
            Malignant neoplasm of breast
            
        
            In your response, return only the name of the condition. Remove words in parenthesis
            like (disorder), so "Aortic valve stenosis (disorder)" would turn to "Aortic valve stenosis".
        
            Do not make anything up, and do not change the name of the condition under any
            circumstances. Thank you!
        """
        
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt4,
                    systemPrompt: systemPrompt
                )
            )
        )
    }
    
    
    private func addConditionAction() {
        data.conditionData.append(MedicalHistoryItem(condition: "", active: false))
    }
    
    private func conditionEntry(item: Binding<MedicalHistoryItem>) -> some View {
        HStack {
            TextField("Condition", text: item.condition)
                .accessibilityLabel("Condition Box")
            Spacer()
            Button(action: {
                item.active.wrappedValue.toggle()
            }) {
                Image(systemName: item.active.wrappedValue ? "checkmark.square" : "square")
                    .accessibilityHidden(true)
                    .accessibilityLabel("Active Box")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }

    private func chatSheetView() -> some View {
        LLMAssistantView(
            pageTitle: .constant("Medical History Assistant"),
            initialQuestion: .constant("Do you have any questions about your medical conditions"),
            prompt: .constant(
                """
                Pretend you are a nurse. Your job is to help the patient
                understand what allergies they have.
                """
            )
        )
    }

    private func loadConditions() async throws {
        let conditions = fhirStore.conditions
        var active = ""
        let invalid = [
            "Medication review due (situation)",
            "Part-time employment (finding)",
            "Stress (finding)",
            "Full-time employment (finding)"
        ]
        for condition in conditions {
            if !invalid.contains(condition.displayName) && !data.conditionData.contains(where: {
                $0.condition == condition.displayName }) {
                let vresource = condition.versionedResource
                switch vresource {
                case .r4(let result as Condition):
                    active = result.clinicalStatus?.coding?[0].code?.value?.string ?? "None"
                default:
                    print("The resource is not an R4 Allergy Intolerance")
                }

                if active == "resolved" {
                    data.conditionData.append(MedicalHistoryItem(condition: condition.displayName, active: false))
                } else {
                    data.conditionData.append(MedicalHistoryItem(condition: condition.displayName, active: true))
                }
            }
        }
        let filter = LLMFiltering(session: session, data: data)
        try await filter.filterConditions()
    }
    
    func delete(at offsets: IndexSet) {
        data.conditionData.remove(atOffsets: offsets)
    }
}


#Preview {
    MedicalHistoryView()
        .previewWith {
            FHIRStore()
        }
}
