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
import ModelsR4
import SpeziFHIR
import SwiftUI


struct SurgeryItem: Identifiable {
    var id = UUID()
    var surgeryName: String = ""
    var startDate: FHIRDate?
    var endDate: FHIRDate?
    var status: String?
    var location: String?
    var notes: [String]?
    var bodySites: [String]?
    var complications: [CodeableConcept]?
}

struct AddSurgery: View {
    @Binding var surgeries: [SurgeryItem]
    @Environment(DataStore.self) var data
    @Environment(NavigationPathWrapper.self) var navigationPath
    
    var body: some View {
        Button(action: {
            let newSurgery = SurgeryItem(surgeryName: "Surgery")
            data.surgeries.append(newSurgery)
            navigationPath.path.append(NavigationViews.inspect)
        }) {
            Image(systemName: "plus")
                .accessibilityLabel(Text("ADD_SURGERY"))
        }
    }
}

struct InspectSurgeryView: View {
    @Binding var surgery: SurgeryItem
    
    var isNew: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Procedure")) {
                TextField("Surgery Name", text: $surgery.surgeryName)
            }
            // Date first
//            Section(header: Text("Complications")) {
//                if surgery.complications != nil {
//                    ForEach(surgery.complications.indices, id: \.self) { index in
//                        TextField("Complication", text: $surgery.complications?[index].text)
//                    }
//                }
//            }
//            if let complications = surgery.complications {
//                Section(header: Text("Complications")) {
//                    ForEach(complications.indices, id: \.self) { index in
//                        TextField("Complication", text: $surgery.complications?[index].text ?? "")
//                    }
//                }
//            }
        }
        .navigationBarTitle(isNew ? "New Surgery" : "Edit Surgery")
    }
}

struct SurgeryView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(DataStore.self) private var data
    
    @State private var addingNewSurgery = false
    
    var body: some View {
        @Bindable var data = data
        VStack {
            surgeryForm
            SubmitButton(nextView: NavigationViews.medication)
                .padding()
        }
        .onAppear {
            self.getProcedures()
        }
        .navigationTitle("Surgical History")
        .navigationBarItems(trailing: AddSurgery(surgeries: $data.surgeries))
        .toolbar {
            EditButton()
        }
    }
    
    private var surgeryElements: some View {
        Group {
            @Bindable var data = data
            ForEach($data.surgeries) { $item in
                NavigationLink(destination: InspectSurgeryView(surgery: $item, isNew: false)) {
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
            Section(header: Text("Please add your past surgeries")) {
                surgeryElements
            }
        }
    }

    func delete(at offsets: IndexSet) {
        data.surgeries.remove(atOffsets: offsets)
    }

    func getProcedures() {
        let procedures = fhirStore.procedures

        for pro in procedures where !data.surgeries.contains(where: { $0.surgeryName == pro.displayName }) {
            let vrs = pro.versionedResource
            switch vrs {
            case .r4(let result as ModelsR4.Procedure):
                addNewProcedure(procedure: result)
            default:
                print("This recourse is not an r4 Proceure")
            }
        }
    }
    
    func addNewProcedure(procedure: ModelsR4.Procedure) {
        var newEntry = SurgeryItem()
        
        if let name = procedure.code {
            newEntry.surgeryName = name.coding?[0].display?.value?.string ?? "Unknown"
        }
        
        let status = procedure.status
        newEntry.status =
            switch status.value ?? EventStatus.unknown {
            case .completed: "Completed"
            case .inProgress: "In Progress"
            case .notDone: "Not Done"
            case .onHold: "On Hold"
            case .stopped: "Stopped"
            case .enteredInError: "Entered in Error"
            default: "Unknown"
            }
        
        if let date = procedure.performed {
            switch date {
            case .period(let period):
                newEntry.startDate = period.start?.value?.date
                newEntry.endDate = period.end?.value?.date
            case .dateTime(let dateTime):
                newEntry.startDate = dateTime.value?.date
            default:
                print("No Date")
            }
        }
        
        if let location = procedure.location {
            newEntry.location = location.display?.value?.string ?? ""
        }
        
        if let notes = procedure.note {
            let stringNotes: [String?] = notes.map { $0.text.value?.string}
            newEntry.notes = stringNotes.compactMap { $0 }
        }
        
        if let bodySites = procedure.bodySite {
            let stringBodySites: [String?] = bodySites.map { $0.text?.value?.string }
            newEntry.bodySites = stringBodySites.compactMap { $0 }
        }
        
        if let complications = procedure.complication {
            let stringComplications: [String?] = complications.map { $0.text }
            newEntry.complications = complications
        }
        
        data.surgeries.append(newEntry)
    }
}

#Preview {
    SurgeryView()
        .previewWith {
            FHIRStore()
        }
}
