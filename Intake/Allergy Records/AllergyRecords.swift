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

struct AllergyItem: Identifiable {
    let id = UUID()
    var allergy: String
    var reaction: [ReactionItem]
}

// struct ReactionViewDetails {
//    var showingReaction: Bool
//    var
// }

struct ChatButton: View {
    // Use @Binding to create a two-way binding to the parent view's showingChat state
    @Binding var showingChat: Bool

    var body: some View {
        Button(action: {
            // Toggle the provided state
            self.showingChat = true
        }) {
            Image(systemName: "message")
                .font(.largeTitle)
                .padding()
                .background(Color.blue)
                .foregroundColor(Color.white)
                .clipShape(Circle())
                .accessibilityLabel("Message")
        }
    }
}

struct AllergyList: View {
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(DataStore.self) private var data
    @State private var showingReaction = false
    @State private var selectedIndex = 0
    @State private var showingChat = false
    @State private var presentingAccount = false

    var body: some View {
        VStack {
            allergyForm
            submitButton
        }
        .onAppear(perform: loadAllergies)
        .sheet(isPresented: $showingChat, content: chatSheetView)
        .sheet(isPresented: $showingReaction, content: editAllergySheetView)
    }
    private var allergyForm: some View {
        Form {
            Section(header: Text("What are your current allergies?")) {
                allergyEntries
                addAllergyButton
                Text("*Click the details to view/edit the reactions")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationBarItems(trailing: EditButton())
        .navigationTitle("Allergies")
    }
        
    private var allergyEntries: some View {
        ForEach(0..<data.allergyData.count, id: \.self) { index in
            allergyButton(index: index)
        }
        .onDelete(perform: delete)
    }

    private var addAllergyButton: some View {
        Button(action: addAllergyAction) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .accessibilityHidden(true)
                Text("Add Field")
            }
        }
    }

    private var submitButton: some View {
        Button(action: submitAction) {
            Text("Submit")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .padding()
    }
        
    private func allergyEntryRow(index: Int) -> some View {
        HStack {
            Text(data.allergyData[index].allergy)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .accessibilityLabel(Text("DETAILS"))
        }
    }
    
    private func allergyButton(index: Int) -> some View {
        Button(action: {
            self.selectedIndex = index
            self.showingReaction = true
        }) {
            allergyEntryRow(index: index)
        }
    }
    
    private func submitAction() {
        navigationPath.path.append(NavigationViews.menstrual)
    }
    
    private func addAllergyAction() {
        data.allergyData.append(AllergyItem(allergy: "", reaction: []))
        self.selectedIndex = data.allergyData.count - 1
        showingReaction = true
    }

    private func chatSheetView() -> some View {
        LLMAssistantView(
            presentingAccount: .constant(false),
            pageTitle: .constant("Allergy Assistant"),
            initialQuestion: .constant("Do you have any questions about your allergies?"),
            prompt: .constant("Pretend you are a nurse. Your job is to help the patient understand what allergies they have.")
        )
    }

    private func editAllergySheetView() -> some View {
        EditAllergyView(index: selectedIndex, showingReaction: $showingReaction)
    }

    private func loadAllergies() {
        var allergies: [FHIRString] = []
        var allReactions: [[ReactionItem]] = []
        let intolerances = fhirStore.allergyIntolerances
        if !intolerances.isEmpty {
            for index in 0...(intolerances.count - 1) {
                let vresource = intolerances[index].versionedResource
                switch vresource {
                case .r4(let result as AllergyIntolerance):
                    allergies.append(result.code?.text?.value as? FHIRString ?? "No Allergy")
                    let reactionsPerAllergy = result.reaction
                    var reactionsForAllergy: [ReactionItem] = []
                    if let reactions = reactionsPerAllergy {
                        for reaction in reactions {
                            let manifestations = reaction.manifestation
                            for manifestation in manifestations {
                                reactionsForAllergy.append(ReactionItem(reaction: manifestation.text?.value?.string ?? "Default"))
                            }
                        }
                    }
                    allReactions.append(reactionsForAllergy)

                default:
                        print("The resource is not an R4 Allergy Intolerance")
                }
            }
        }
        if !allergies.isEmpty {
            for index in 0...(allergies.count - 1) {
                data.allergyData.append(
                    AllergyItem(allergy: allergies[index].string, reaction: allReactions[index])
                )
            }
        }
    }

    func delete(at offsets: IndexSet) {
        data.allergyData.remove(atOffsets: offsets)
    }
}

// #Preview {
//    AllergyList()
//        .previewWith {
//            FHIRStore()
//        }
// }
