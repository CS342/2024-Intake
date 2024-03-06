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
    var date: String?
//    var location: String?
//    var complications: String?
//    var notes: String?
//    var status: String?
//    var code: String?
}

struct AddSurgeryButton: View {
    @Binding var surgeries: [SurgeryItem]

    var body: some View {
        Button(action: {
            // Action to add new item
            surgeries.append(SurgeryItem(surgeryName: "Surgery", date: ""))
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .accessibilityLabel(Text("ADD_SURGERY"))
                Text("Add Field")
            }
        }
    }
}

struct InspectSurgeryView: View {
    @Binding var surgery: SurgeryItem
    
    var body: some View {
        Form {
            Section(header: Text("Surgery")) {
                TextField("Surgery Name", text: $surgery.surgeryName)
            }
//            if let date = surgery.date {
//                @Bindable var date = date
//                
//                Section(header: Text("Date")) {
//                    if editMode?.wrappedValue.isEditing == true {
//                        TextField("Date", text: $date)
//                    } else {
//                        Text(date)
//                    }
//                }
//            }
        }
        .listStyle(.grouped)
        .toolbar {
            EditButton()
        }
    }
}


/*
 List {
     Section(header: Text("What is your surgical history?")) {
         // Extension: Sort these by date
         ForEach($data.surgeries) { $item in
             if editMode?.wrappedValue.isEditing == true {
                 TextField("Surgery", text: $item.surgeryName)
             } else {
                 NavigationLink(destination: InspectSurgeryView(surgery: $item)) {
                     Label(item.surgeryName, systemImage: "arrowtriangle.right")
                         .labelStyle(.titleOnly)
                 }
             }
         }
         .onDelete(perform: delete)
         if editMode?.wrappedValue.isEditing == true {
             AddSurgeryButton(surgeries: $data.surgeries)
         }
     }
 }
 */

struct SurgeryView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(DataStore.self) private var data
    @Environment(\.editMode) private var editMode

    var body: some View {
        VStack {
            surgeryForm
            SubmitButton(nextView: NavigationViews.medication)
            .padding()
        }
        .onAppear {
            self.getProcedures()
        }
        .navigationTitle("Surgical History")
        .navigationBarItems(trailing: NavigationLink(destination: SurgeryLLMAssistant(presentingAccount: .constant(false))) {
            Text("Chat")
        })
        .toolbar {
            EditButton()
        }
    }
    
    private var surgeryElements: some View {
        Group {
            @Bindable var data = data
            ForEach($data.surgeries) { $item in
                NavigationLink(destination: InspectSurgeryView(surgery: $item)) {
                    Label(item.surgeryName, systemImage: "arrowtriangle.right")
                        .labelStyle(.titleOnly)
                }
            }
            .onDelete(perform: delete)
        }
    }
    
    private var surgeryForm: some View {
        Form {
            @Bindable var data = data
            Section(header: Text("What is your surgical history?")) {
                surgeryElements
                AddSurgeryButton(surgeries: $data.surgeries)
            }
        }
    }

    func delete(at offsets: IndexSet) {
        data.surgeries.remove(atOffsets: offsets)
    }

    func getProcedures() {
        let procedures = fhirStore.procedures
//      print(procedures)

        for pro in procedures where !data.surgeries.contains(where: { $0.surgeryName == pro.displayName }) {
            var newEntry = SurgeryItem(surgeryName: pro.displayName)

            if let date = pro.date?.formatted() {
                newEntry.date = date
            }

            data.surgeries.append(newEntry)
        }
    }
}

#Preview {
    SurgeryView()
        .previewWith {
            FHIRStore()
        }
}
