//
//  MedicalHistoryView.swift
//  Intake
//
//  Created by Akash Gupta on 1/30/24.
//

import Foundation
import ModelsR4
import SpeziFHIR
import SwiftUI

struct AllergyItem: Identifiable {
    var id = UUID()
    var condition: String
    var reaction: String
}


struct AllergyView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @State private var allergyRecords: [AllergyItem] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach($allergyRecords) { $item in
                    NavigationLink(destination: ReactionView(reactionRecords: [ReactionItem(reaction: "hello")], name: item.condition)) {
                        HStack {
                            Button(action: {
                                // Action to delete this item
                                if let index = allergyRecords.firstIndex(where: { $0.id == item.id }) {
                                    allergyRecords.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark.circle")
                            }
                            TextField("Condition", text: $item.condition)
                        }
                    }
                }
                .onDelete(perform: delete)
                
                Button(action: {
                    // Action to add new item
                    allergyRecords.append(AllergyItem(condition: "", reaction: ""))
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Field")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("5. What are your current allergies?")
                        .font(.system(size: 28)) // Choose a size that fits
                        .lineLimit(1)
                        .minimumScaleFactor(0.5) // Adjusts the font size to fit the width of the line
                }
            }
            .onAppear {
                // Set a breakpoint on the next line to inspect `fhirStore.conditions`
                var allergies: [FHIRString] = []
//                var reactions: [String] = []
                let intolerances = fhirStore.allergyIntolerances
                if intolerances.count > 0 {
                    for i in 0...(intolerances.count - 1) {
                        let vr = intolerances[i].versionedResource
                        switch vr {
                        case .r4(let result as AllergyIntolerance):
                            allergies.append(result.code?.text?.value as? FHIRString ?? "No Allergy")
//                            var reactions_per_allergy = result.reaction
//                            var reactions_for_allergy: [String] = []
//                            if reactions_per_allergy != nil {
//                                reactions_for_allergy = reactions_per_allergy.map { reaction in
//                                    reaction.manifestation[0].text.value
//                                }
//                            }
//                            
                        default:
                            // Handle other cases or default case
                            print("The resource is not an R4 Allergy Intolerance")
                    }
                }
            }
                self.allergyRecords = allergies.map { allergy in
                    AllergyItem(condition: allergy.string, reaction: "")
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        allergyRecords.remove(atOffsets: offsets)
    }
}
        

#Preview {
    AllergyView()
        .previewWith {
            FHIRStore()
        }
}
