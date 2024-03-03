//  MedicalHistoryView.swift
//  Intake
//
//  Created by Akash Gupta on 1/30/24.
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
import SwiftUI

struct MedicalHistoryItem: Identifiable {
    var id = UUID()
    var condition: String
    var active: Bool
}

struct MedicalHistoryView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(DataStore.self) private var data
    @State private var showAddSheet = false
    @State private var showingChat = false

    var body: some View {
        VStack {
            medicalHistoryForm
            SubmitButton(nextView: NavigationViews.surgical)
                .padding()
        }
        .onAppear(perform: loadConditions)
        .sheet(isPresented: $showingChat, content: chatSheetView)
    }

    private var medicalHistoryForm: some View {
        Form {
            Section(header: Text("Please list conditions you have had")) {
                conditionEntries
                addConditionButton
                instructionText
            }
        }
        .navigationTitle("Medical History")
        .navigationBarItems(trailing: EditButton())
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
                Image(systemName: "plus.circle.fill")
                    .accessibilityHidden(true)
                Text("Add Field")
            }
        }
    }

    private var instructionText: some View {
        Text("""
            *Check the box if you currently have the condition. /
            *Uncheck the box if you had the condition in the past
            """)
        .font(.caption)
        .foregroundColor(.gray)
    }
    
    private func addConditionAction() {
        data.conditionData.append(MedicalHistoryItem(condition: "", active: false))
    }
    
    private func conditionEntry(item: Binding<MedicalHistoryItem>) -> some View {
        HStack {
            TextField("Condition", text: item.condition)
            Spacer()
            Button(action: {
                item.active.wrappedValue.toggle()
            }) {
                Image(systemName: item.active.wrappedValue ? "checkmark.square" : "square")
                    .accessibilityHidden(true)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }

    private func chatSheetView() -> some View {
        LLMAssistantView(
            presentingAccount: .constant(false),
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

    private func loadConditions() {
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
        print(data.conditionData)
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
