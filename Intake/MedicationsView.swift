//
//  MedicationsView.swift
//  Intake
//
//  Created by Kate Callon on 2/4/24.
//

import Foundation
import SwiftUI
import SpeziFHIR

struct MedicationItem: Identifiable {
    var id = UUID()
    var medication: String
}

struct MedicationsView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @State private var medications: [MedicationItem] = []

    var body: some View {
        NavigationView {
            List {
                ForEach($medications) { $item in
                    HStack {
                        TextField("Medication", text: $item.medication)
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
                    medications.append(MedicationItem(medication: ""))
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Medication")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Patient's Medications")
                        .font(.system(size: 28)) // Choose a size that fits
                        .lineLimit(1)
                        .minimumScaleFactor(0.5) // Adjusts the font size to fit the width of the line
                }
            }
            .onAppear {
                let patientMedications = fhirStore.medications
                for medication in patientMedications {
                    if !self.medications.contains(where: { $0.medication == medication.displayName }) {
                        self.medications.append(MedicationItem(medication: medication.displayName))
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
    MedicationsView()
        .previewWith {
            FHIRStore()
        }
        
}
