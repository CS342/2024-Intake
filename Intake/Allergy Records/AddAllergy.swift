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
                        Section(header:
                            HStack {
                                Text("Reactions")
                                Spacer()
                                EditButton()
                            }
                        ) {
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
    
    init(index: Int, showingReaction: Binding<Bool>) {
        self._index = State(initialValue: index)
        self._showingReaction = showingReaction
    }
           
    func saveCondition() {
        print("Condition Saved:, Active Status:")
    }
    
    func delete(at offsets: IndexSet) {
        data.allergyData[index].reaction.remove(atOffsets: offsets)
    }
}


//#Preview {
//    EditAllergyView(allergyItem: AllergyItem(allergy: "", reaction: []), showingReaction: <#T##Binding<Bool>#>, allergyRecords: <#T##Binding<[AllergyItem]>#>, showingReaction: .constant(true), allergyRecords: .constant([]))
//        .previewWith {
//            FHIRStore()
//        }
//}
