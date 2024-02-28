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
            ZStack {
            NavigationView {
                Form { // Use Form instead of List
                    Section(header: Text("What are your current allergies?")) {
                        ForEach(0..<data.allergyData.count, id: \.self) { index in
                                Button(action: {
                                    self.selectedIndex = index
                                    self.showingReaction = true
                                }) {
                                    HStack {
                                        Text(data.allergyData[index].allergy)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .accessibilityLabel(Text("DETAILS"))
                                    }
                                }
                        }
                        .onDelete(perform: delete)

                        Button(action: {
                            // Action to add new item
                            data.allergyData.append(AllergyItem(allergy: "", reaction: []))
                            self.selectedIndex = data.allergyData.count - 1
                            showingReaction = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Field")
                            }
                        }
                        Text("*Click the details to view/edit the reactions")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .navigationBarItems(trailing: EditButton())
                .sheet(isPresented: $showingReaction) {
                    EditAllergyView(index: selectedIndex, showingReaction: $showingReaction)
                }
                .navigationTitle("Allergies")
                VStack {
                    Spacer() // Pushes everything to the bottom
                    ChatButton(showingChat: $showingChat) // Utilize the ChatButton view
                        .padding(.trailing, 20) // Adjust padding as needed
                        .padding(.bottom, 20) // Adjust for spacing from the bottom edge
                }
                .zIndex(1) // Ensure the chat button is above the form
            }
        }
        Button(action: {
            navigationPath.path.append(NavigationViews.social)
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
    .onAppear {
        loadAllergies()
    }
    .sheet(isPresented: $showingChat) {
        LLMAssistantView(presentingAccount: .constant(false),
                        pageTitle: .constant("Allergy Assistant"),
                        initialQuestion: .constant("Do you have any questions about your allergies"),
                        prompt: .constant("Pretend you are a nurse. Your job is to help the patient understand what allergies they have."))
        }
    }

    private func loadAllergies() {
        var allergies: [FHIRString] = []
        var r: [[ReactionItem]] = []
        let intolerances = fhirStore.allergyIntolerances
        if intolerances.count > 0 {
            for i in 0...(intolerances.count-1) {
                let vr = intolerances[i].versionedResource
                switch vr {
                    case .r4(let result as AllergyIntolerance):
                        allergies.append(result.code?.text?.value as? FHIRString ?? "No Allergy")
                        let reactions_per_allergy = result.reaction
                        var reactions_for_allergy: [ReactionItem] = []
                        if let reactions = reactions_per_allergy {
                            for reaction in reactions {
                                let manifestations = reaction.manifestation
                                for manifestation in manifestations {
                                    reactions_for_allergy.append(ReactionItem(reaction: manifestation.text?.value?.string ?? "Default"))
                                }
                             }
                        }
                        r.append(reactions_for_allergy)

                    default:
                        print("The resource is not an R4 Allergy Intolerance")
                }
            }
        }
        if allergies.count > 0 {
            for i in 0...(allergies.count-1) {
                data.allergyData.append(
                    AllergyItem(allergy: allergies[i].string, reaction: r[i])
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
