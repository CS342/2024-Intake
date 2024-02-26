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
import SpeziFHIR
import SwiftUI
import ModelsR4

struct MedicalHistoryItem: Identifiable {
    var id = UUID()
    var condition: String
    var active: Bool
}


struct MedicalHistoryView: View {
    @Environment(FHIRStore.self) private var fhirStore
//    @EnvironmentObject private var data: Data
    @EnvironmentObject private var navigationPath: NavigationPathWrapper
    @State private var medicalHistory: [MedicalHistoryItem] = []
    @State private var showAddSheet = false
    @State private var showingChat = false
    
    var body: some View {
        VStack {
            NavigationView {
                ZStack {
                    Form { // Use Form instead of List
                        Section(header: Text("Please list conditions you have had")) {
                            ForEach($medicalHistory) { $item in
                                if item.active == true {
                                    HStack {
                                        TextField("Condition", text: $item.condition)
                                        Spacer()
                                        Button(action: {
                                            item.active.toggle()
                                        }) {
                                            Image(systemName: item.active ? "checkmark.square" : "square")
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            }
                            .onDelete(perform: delete)
                            ForEach($medicalHistory) { $item in
                                if item.active == false {
                                    HStack {
                                        TextField("Condition", text: $item.condition)
                                        Spacer()
                                        Button(action: {
                                            item.active.toggle()
                                        }) {
                                            Image(systemName: item.active ? "checkmark.square" : "square")
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            }
                            .onDelete(perform: delete)
                            Button(action: {
                                // Action to add new item
                                medicalHistory.append(MedicalHistoryItem(condition: "", active: false))
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Field")
                                }
                            }
                            Text("""
                                *Check the box if you currently have the condition. /
                                *Uncheck the box if you had the condition in the past
                                """)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .zIndex(1)
                        }
                        
                    }
                    .navigationTitle("Medical History")
                    .navigationBarItems(trailing: EditButton())
                    .onAppear {
                        // Set a breakpoint on the next line to inspect `fhirStore.conditions`
                        loadConditions()
                    }
                    .sheet(isPresented: $showingChat) {
                        LLMAssistantView(presentingAccount: .constant(false),
                                         pageTitle: .constant("Medical History Assistant"),
                                         initialQuestion: .constant("Do you have any questions about your medical conditions"),
                                         prompt: .constant("Pretend you are a nurse. Your job is to help the patient understand what allergies they have."))
                    }
                    VStack {
                        Spacer() // Pushes the button to the bottom
                        HStack {
                            Spacer() // Pushes the button to the trailing edge
                            Button(action: {
                                self.showingChat.toggle() // Toggle the state to show the chat
                            }) {
                                Image(systemName: "message")
                                    .font(.largeTitle)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(Color.white)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing) // Add right padding if needed
                        }
                    .padding(.bottom, 15) // Adjust this value to raise the chat button above the submit button
                    }
                    .zIndex(1) // Make sure the chat button is above the Form
                }
            }

            Button(action: {
                self.navigationPath.append_item(item: NavigationViews.surgical)
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
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
            if !invalid.contains(condition.displayName) && !medicalHistory.contains(where: {
                $0.condition == condition.displayName }) {
                let vr = condition.versionedResource
                switch vr {
                    case .r4(let result as Condition):
                    active = result.clinicalStatus?.coding?[0].code?.value?.string ?? "None"
                    default:
                        print("The resource is not an R4 Allergy Intolerance")
                }
                
                if active == "resolved" {
                    medicalHistory.append(MedicalHistoryItem(condition: condition.displayName, active: false))
                } else {
                    medicalHistory.append(MedicalHistoryItem(condition: condition.displayName, active: true))
                }
                
            }
        }
    }
        func delete(at offsets: IndexSet) {
            medicalHistory.remove(atOffsets: offsets)
        }
    }
        

#Preview {
    MedicalHistoryView()
        .previewWith {
            FHIRStore()
        }
}
