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


struct ReactionPDF: View {
    @State private var index: Int
    @Environment(DataStore.self) private var data
    @Binding private var showingReaction: Bool
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    if data.allergyData[index].reaction.isEmpty {
                        Text("No Reactions")
                    }
                    ForEach(data.allergyData[index].reaction) { item in
                        Text(item.reaction)
                    }
                }
                .navigationTitle("\(data.allergyData[index].allergy) Reactions")
            }
        }
    }
    
    init(index: Int, showingReaction: Binding<Bool>) {
        self._index = State(initialValue: index)
        self._showingReaction = showingReaction
    }
}

// #Preview {
//    EditAllergyView(allergyItem: AllergyItem(allergy: "", reaction: []), showingReaction: <#T##Binding<Bool>#>, allergyRecords: <#T##Binding<[AllergyItem]>#>, showingReaction: .constant(true), allergyRecords: .constant([]))
//        .previewWith {
//            FHIRStore()
//        }
// }
