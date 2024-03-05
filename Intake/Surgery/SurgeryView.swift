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
    var dateLabel: String?
    var date: String?
//    var location: String?
    var complications: [String] = []
//    var notes: String?
//    var status: String?
//    var code: String?
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
        .navigationBarTitle(isNew ? "New Surgery" : "Edit Surgery")
//        .toolbar {
//            EditButton()
//        }
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
            newEntry.surgeryName = name.text?.value?.string ?? "Surgery"
        }
        
        // allergies.append(result.code?.text?.value as? FHIRString ?? "No Allergy")
        
        var newDate: String
        var dateLabel: String
        if let date = procedure.performed {
            switch date {
            case .age:
                newDate = date.rawValue
                    
//                    .code?.text?.string ?? ""
                dateLabel = "Age"
            case .dateTime:
                
                dateLabel = "Date"
            case .period:
                
                dateLabel = "Period"
            case .range:
                
                dateLabel = "Range"
            case .string:
                
                dateLabel = "Date"
            default:
                print("Invalid date format")
            }
        }
        
        if let complications = procedure.complication {
            newEntry.complications = complications.map { $0.text?.value?.string ?? "" }
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
