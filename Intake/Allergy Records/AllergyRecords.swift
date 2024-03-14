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
    @State private var newAllergy = AllergyItem(allergy: "", reaction: [])
    
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession

    var body: some View {
        if loaded.allergyData {
            VStack {
                allergyForm
                /**/
                if FeatureFlags.skipToScrollable {
                    SubmitButton(nextView: NavigationViews.pdfs)
                        .padding()
                }
                else if data.generalData.sex == "Female" {
                    SubmitButton(nextView: NavigationViews.menstrual)
                        .padding()
                } else {
                    SubmitButton(nextView: NavigationViews.smoking)
                        .padding()
                }
            }
            .sheet(isPresented: $showingChat, content: chatSheetView)
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
                Text("*Click the details to view/edit the reactions")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Allergies")
        .navigationBarItems(trailing: addAllergyButton)
        .navigationBarItems(trailing: NavigationLink(destination: AllergyLLMAssistant(presentingAccount: $presentingAccount)) {
            Text("Chat")
        })
    }
        
    private var allergyEntries: some View {
        Group {
            @Bindable var data = data
            ForEach($data.allergyData) { $item in
                NavigationLink(destination: EditAllergyView(item: $item)) {
                    Label(item.allergy, systemImage: "arrowtriangle.right")
                        .labelStyle(.titleOnly)
                }
            }
            .onDelete(perform: delete)
        }
    }

    private var addAllergyButton: some View {
        Button(action: {
            let newAllergy = AllergyItem(allergy: "", reaction: [])
            navigationPath.path.append(NavigationViews.newAllergy)
            data.allergyData.append(newAllergy)
        }) {
            Image(systemName: "plus")
                .accessibilityLabel(Text("Add_allergy"))
        }
    }
    
    init() {
        let systemPrompt = """
            You are a helpful assistant that filters lists of allergies. You will be given\
            an array of strings. Each string will be the name of a allergy, but we only want\
            to keep the names of relevant allergies.
        
            For example, if you are given the following list:
            Allergy to substance (finding), Latex (substance), Bee venom (substance), Mold (organism),\
            House dust mite (organism)Animal dander (substance), Grass pollen (substance),\
            Tree pollen (substance), Aspirin
        
            you should return something like this:
            Latex, Bee venom, Mold, House dust mite, Animal dander, Grass pollen, Tree pollen, Aspirin
        
            Another example would be if you are given the following list:
            Animal dander (substance), Penicillin V, Peanut (substance)
        
            you should return something like this:
            Animal dander, Penicillin V, Peanut
        
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
    
    private func submitAction() {
        navigationPath.path.append(NavigationViews.menstrual)
    }

    private func chatSheetView() -> some View {
        LLMAssistantView(
            presentingAccount: .constant(false),
            pageTitle: .constant("Allergy Assistant"),
            initialQuestion: .constant("Do you have any questions about your allergies?"),
            prompt: .constant("Pretend you are a nurse. Your job is to help the patient understand what allergies they have.")
        )
    }
    
    private func removeTextWithinParentheses(from string: String) -> String {
        let pattern = "\\s*\\([^)]+\\)"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(string.startIndex..., in: string)
            return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
            return string
        }
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
                                var reactionName = manifestation.text?.value?.string
                                reactionName = removeTextWithinParentheses(from: reactionName ?? "")
                                reactionsForAllergy.append(ReactionItem(reaction: reactionName ?? ""))
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
