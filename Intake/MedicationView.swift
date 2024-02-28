//
//  MedicationView.swift
//  Intake
//
//  Created by Kate Callon on 2/6/24.
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

struct MedicationItem: Identifiable {
    var id = UUID()
    var medicationName: String
}

struct MedicationView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @State private var medications: [MedicationItem] = []

        var body: some View {
            NavigationView { // swiftlint:disable:this closure_body_length
                VStack { // swiftlint:disable:this closure_body_length
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
                                        .accessibilityLabel(Text("DELETE_MEDICATION"))
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
                                    .accessibilityLabel(Text("ADD_MEDICATION"))
                                Text("Add Field")
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Please list your current medications.")
                                .font(.system(size: 28)) // Choose a size that fits
                                .lineLimit(1)
                                .minimumScaleFactor(0.5) // Adjusts the font size to fit the width of the line
                        }
                    }
                    Button(action: {
                        // Save output to Firestore and navigate to next screen
                        // Still need to save output to Firestore
                        navigationPath.path.append(NavigationViews.allergies)
                    }) {
                        Text("Submit")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .onAppear {
                    // Set a breakpoint on the next line to inspect `fhirStore.conditions`
                    let patientMedications = fhirStore.medications
                    for medication in patientMedications where !self.medications.contains(where: { $0.medicationName == medication.displayName }) {
                        self.medications.append(MedicationItem(medicationName: medication.displayName))
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
