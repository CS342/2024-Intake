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


struct ReactionSectionView: View {
    @Environment(DataStore.self) private var data
    var index: Int
    
    
    var body: some View {
        Form { // Use Form instead of List
            Section(header: headerTitle) {
                @Bindable var data = data
                
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
    }
    
    private var headerTitle: some View {
        HStack {
            Text("Reactions")
            Spacer()
            EditButton()
        }
    }
    
    
    func delete(at offsets: IndexSet) {
        data.allergyData[index].reaction.remove(atOffsets: offsets)
    }
}
