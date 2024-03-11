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
import SpeziLLM
import SpeziLLMOpenAI
import SwiftUI

struct AllergyItem: Identifiable, Equatable {
    let id = UUID()
    var allergy: String
    var reaction: [ReactionItem]
    
    static func == (lhs: AllergyItem, rhs: AllergyItem) -> Bool {
        lhs.allergy == rhs.allergy
    }
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
    @Environment(LoadedWrapper.self) private var loaded
    
    @State private var showingReaction = false
    @State private var selectedIndex = 0
    @State private var showingChat = false
    @State private var presentingAccount = false
    
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession
    
    init() {
        let systemPrompt = """
            You are a helpful assistant that filters lists of allergies. You will be given\
            an array of strings. Each string will be the name of a allergy.
        
            For example, if you are given the following list:
            Mammography (procedure), Certification procedure (procedure), Cytopathology\
            procedure, preparation of smear, genital source (procedure), Transplant of kidney\
            (procedure),
        
            you should return something like this:
            Transplant of kidney, Mammography.
        
            In your response, return only the name of the allergy. Remove words in parenthesis
            like (disorder), so "Aortic valve stenosis (disorder)" would turn to "Aortic valve stenosis".
        
            Do not make anything up, and do not change the name of the condition under any
            circumstances. Thank you!
        """
        
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: systemPrompt
                )
            )
        )
    }

    var body: some View {
        if loaded.allergyData {
            VStack {
                allergyForm
                SubmitButton(nextView: NavigationViews.menstrual)
                    .padding()
            }
            .sheet(isPresented: $showingChat, content: chatSheetView)
            .sheet(isPresented: $showingReaction, content: editAllergySheetView)
        } else {
            ProgressView()
                .task {
                    do {
                        try await loadAllergies()
                    } catch {
                        print("Failed to load")
                    }
                    loaded.allergyData = true
                }
        }
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
        .navigationBarItems(trailing: NavigationLink(destination: AllergyLLMAssistant(presentingAccount: $presentingAccount)) {
            Text("Chat")
        })
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

    private func loadAllergies() async throws {
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
            for index in 0...(allergies.count - 1) where !data.allergyData.contains(where: { $0.allergy == allergies[index].string }) {
                data.allergyData.append(
                    AllergyItem(allergy: allergies[index].string, reaction: allReactions[index])
                )
            }
        }
        
        let filter = LLMFiltering(session: session, data: data)
        try await filter.filterAllergies()
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
