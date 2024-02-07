//
//  MedicationView.swift
//  Intake
//
//  Created by Kate Callon on 2/6/24.
//

import Foundation
import SpeziFHIR
import SwiftUI

struct MedicationItem: Identifiable {
    var id = UUID()
    var medicationName: String
}


struct MedicationView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @State private var medications: [MedicationItem] = []

        var body: some View {
            NavigationView {
                List {
                    ForEach($medications) { $item in
                        HStack {
                            TextField("Medication", text: $item.medicationName)
                            Button(action: {
                                // Action to delete this item
                                if let index = medications.firstIndex(where: { $0.id == item.id }) {
                                    medications.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark.circle")
                            }
                        }
                    }
                    .onDelete(perform: delete)
                    
                    Button(action: {
                        // Action to add new item
                        medications.append(MedicationItem(medicationName: ""))
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
                        Text("3. Please list your current medications.")
                            .font(.system(size: 28)) // Choose a size that fits
                            .lineLimit(1)
                            .minimumScaleFactor(0.5) // Adjusts the font size to fit the width of the line
                    }
                }
                .onAppear {
                    // Set a breakpoint on the next line to inspect `fhirStore.conditions`
                    let patientMedications = fhirStore.medications
                                    for medication in patientMedications {
                                        if !self.medications.contains(where: { $0.medicationName == medication.displayName }) {
                                            self.medications.append(MedicationItem(medicationName: medication.displayName))
                                        }
                    }
                }
            }
        }
        
        func delete(at offsets: IndexSet) {
            medications.remove(atOffsets: offsets)
        }
    }
        

#Preview {
    MedicationView()
        .previewWith {
            FHIRStore()
        }
}
