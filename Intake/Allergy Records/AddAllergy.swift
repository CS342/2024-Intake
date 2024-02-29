//
//  AddConditionView.swift
//  Intake
//
//  Created by Akash Gupta on 2/19/24.
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


struct EditAllergyView: View {
    @State private var index: Int
    @Environment(DataStore.self) private var data
    @Binding private var showingReaction: Bool
    var body: some View {
           NavigationView {
               VStack(alignment: .leading, spacing: 10) {
                   @Bindable var data = data
                   TextField("Allergy Name", text: $data.allergyData[index].allergy)
                           .textFieldStyle(RoundedBorderTextFieldStyle())
                           .padding([.horizontal, .top])
                   Form { // Use Form instead of List
                        Section(header: headerTitle) {
                            ForEach($data.allergyData[index].reaction) { $item in
                                HStack {
                                    TextField("Reactions", text: $item.reaction)
                                }
                            }
                            .onDelete(perform: delete)
                            Button(action: {
                                data.allergyData[index].reaction.append(ReactionItem(reaction: ""))
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .accessibilityLabel(Text("ADD_REACTION"))
                                    Text("Add Field")
                                }
                            }
                        }
                   }
                   Spacer()
                   saveButton
               }
               .navigationBarTitle("Allergy")
           }
    }
    
    private var saveButton: some View {
        Button(action: {
            showingReaction = false
        }) {
            Text("Save")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding()
    }
    
    private var headerTitle: some View {
        HStack {
            Text("Reactions")
            Spacer()
            EditButton()
        }
    }

    
    init(index: Int, showingReaction: Binding<Bool>) {
        self._index = State(initialValue: index)
        self._showingReaction = showingReaction
    }

    func delete(at offsets: IndexSet) {
        data.allergyData[index].reaction.remove(atOffsets: offsets)
    }
}

// #Preview {
//    EditAllergyView(allergyItem: AllergyItem(allergy: "", reaction: []), showingReaction: <#T##Binding<Bool>#>, allergyRecords: <#T##Binding<[AllergyItem]>#>, showingReaction: .constant(true), allergyRecords: .constant([]))
//        .previewWith {
//            FHIRStore()
//        }
// }