//
//  MedicalHistoryView.swift
//  Intake
//
//  Created by Akash Gupta on 1/30/24.
//

import Foundation
import SwiftUI
import SpeziFHIR

struct MedicalHistoryItem: Identifiable {
    var id = UUID()
    var condition: String
}


struct MedicalHistoryView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @State private var medicalHistory: [MedicalHistoryItem] = []

        var body: some View {
            NavigationView {
                List {
                    ForEach($medicalHistory) { $item in
                        HStack {
                            TextField("Condition", text: $item.condition)
                            Button(action: {
                                // Action to delete this item
                                if let index = medicalHistory.firstIndex(where: { $0.id == item.id }) {
                                    medicalHistory.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark.circle")
                            }
                        }
                    }
                    .onDelete(perform: delete)
                    
                    Button(action: {
                        // Action to add new item
                        medicalHistory.append(MedicalHistoryItem(condition: ""))
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
                        Text("2. Please list current conditions you have")
                            .font(.system(size: 28)) // Choose a size that fits
                            .lineLimit(1)
                            .minimumScaleFactor(0.5) // Adjusts the font size to fit the width of the line
                    }
                }
                .onAppear {
                    // Set a breakpoint on the next line to inspect `fhirStore.conditions`
                    let conditions = fhirStore.conditions
                    print(conditions)
                    let invalid = ["Medication review due (situation)", "Part-time employment (finding)",
                                    "Stress (finding)", "Full-time employment (finding)", ]
                    for condition in conditions {
                        if !invalid.contains(condition.displayName) && !self.medicalHistory.contains(where: { $0.condition == condition.displayName }){
                            self.medicalHistory.append(MedicalHistoryItem(condition: condition.displayName))
                        }
                    }
                }
            }
        }
        
        func delete(at offsets: IndexSet) {
            medicalHistory.remove(atOffsets: offsets)
        }
    }
        


#Preview {
    MedicalHistoryView()
        .previewWith {
            FHIRStore()
        }
        
}