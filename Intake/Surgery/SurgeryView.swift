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
import SwiftUI
import SpeziFHIR

struct SurgeryItem: Identifiable {
    var id = UUID()
    var surgeryName: String
}


struct SurgeryView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @State private var surgeries: [SurgeryItem] = []

        var body: some View {
            NavigationView {
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
                            Text("Add Field")
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("4. Please list your previous surgeries.")
                            .font(.system(size: 28)) // Choose a size that fits
                            .lineLimit(1)
                            .minimumScaleFactor(0.5) // Adjusts the font size to fit the width of the line
                    }
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
