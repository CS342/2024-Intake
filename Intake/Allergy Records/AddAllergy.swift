//
//  AddConditionView.swift
//  Intake
//
//  Created by Akash Gupta on 2/19/24.
//

import Foundation
import SwiftUI
import SpeziFHIR


struct EditAllergyView: View {
    @State private var index: Int
    @Binding private var showingReaction: Bool
    @Binding private var allergyRecords: [AllergyItem]
    var body: some View {
           NavigationView {
               VStack(alignment: .leading, spacing: 10) {
                       TextField("Allergy Name", text: $allergyRecords[index].allergy)
                           .textFieldStyle(RoundedBorderTextFieldStyle())
                           .padding([.horizontal, .top])
                   Form { // Use Form instead of List
                        Section(header:
                            HStack {
                                Text("Reactions")
                                Spacer()
                                EditButton()
                            }
                        ) {
                            ForEach($allergyRecords[index].reaction) { $item in
                                HStack {
                                    TextField("Reactions", text: $item.reaction)
                                }
                            }
                            .onDelete(perform: delete)
                            Button(action: {
                                allergyRecords[index].reaction.append(ReactionItem(reaction: ""))
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
                   .padding(.horizontal)
               }
               .navigationBarTitle("Allergy")
           }
    }
    
    init(index: Int, showingReaction: Binding<Bool>, allergyRecords: Binding<[AllergyItem]>) {
        self._index = State(initialValue: index)
        self._showingReaction = showingReaction
        self._allergyRecords = allergyRecords
    }
           
    func saveCondition() {
        print("Condition Saved:, Active Status:")
    }
    
    func delete(at offsets: IndexSet) {
        self.allergyRecords[index].reaction.remove(atOffsets: offsets)
    }
}


//#Preview {
//    EditAllergyView(allergyItem: AllergyItem(allergy: "", reaction: []), showingReaction: <#T##Binding<Bool>#>, allergyRecords: <#T##Binding<[AllergyItem]>#>, showingReaction: .constant(true), allergyRecords: .constant([]))
//        .previewWith {
//            FHIRStore()
//        }
//}
