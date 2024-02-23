//
//  SurgeryView.swift
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

struct SurgeryItem: Identifiable {
    var id = UUID()
    var surgeryName: String
}


struct SurgeryView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @EnvironmentObject private var navigationPath: NavigationPathWrapper
    @State private var surgeries: [SurgeryItem] = []

        var body: some View {
            NavigationView { // swiftlint:disable:this closure_body_length
                VStack { // swiftlint:disable:this closure_body_length
                    List {
                        ForEach($surgeries) { $item in
                            HStack {
                                TextField("Surgery", text: $item.surgeryName)
                                Button(action: {
                                    // Action to delete this item
                                    if let index = surgeries.firstIndex(where: { $0.id == item.id }) {
                                        surgeries.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .accessibilityLabel(Text("DELETE_SURGERY"))
                                }
                            }
                        }
                        .onDelete(perform: delete)
                        
                        Button(action: {
                            // Action to add new item
                            surgeries.append(SurgeryItem(surgeryName: ""))
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .accessibilityLabel(Text("ADD_SURGERY"))
                                Text("Add Field")
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
//                        EditButton()
                        ToolbarItem(placement: .principal) {
                            Text("Please list your previous surgeries.")
                                .font(.system(size: 28)) // Choose a size that fits
                                .lineLimit(1)
                                .minimumScaleFactor(0.5) // Adjusts the font size to fit the width of the line
                        }
                    }
                    Button(action: {
                        // Save output to Firestore and navigate to next screen
                        // Still need to save output to Firestore
                        self.navigationPath.append_item(item: NavigationViews.medication)
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
            }
            }
        
        func delete(at offsets: IndexSet) {
            surgeries.remove(atOffsets: offsets)
        }
    }
        

#Preview {
    SurgeryView()
        .previewWith {
            FHIRStore()
        }
}
