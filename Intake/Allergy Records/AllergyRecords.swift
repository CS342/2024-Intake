//
//  MedicalHistoryView.swift
//  Intake
//
//  Created by Akash Gupta on 1/30/24.
//

import Foundation
import ModelsR4
import SwiftUI
import SpeziFHIR


struct ReactionItem: Identifiable {
    var id = UUID()
    var reaction: String
}


struct AllergyItem: Identifiable {
    var id = UUID()
    var condition: String
    var reactions: [ReactionItem]
}

struct AllergyView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @State private var allergyRecords: [AllergyItem] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach($allergyRecords) { $item in
                    NavigationLink(destination: ReactionView(reactionRecords: item.reactions, name: item.condition)) {
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
                    allergyRecords.append(AllergyItem(condition: "", reactions: []))
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
                            
//
                        default:
                            print("The resource is not an R4 Allergy Intolerance")
                        }
                    }
                }
                if allergies.count > 0 {
                    for i in 0...(allergies.count-1) {
                        self.allergyRecords.append(
                            AllergyItem(condition: allergies[i].string, reactions: r[i]))
                    }
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
