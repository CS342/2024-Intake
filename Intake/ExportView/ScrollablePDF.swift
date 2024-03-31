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


struct HeaderTitle: View {
    @Environment(NavigationPathWrapper.self) private var navigationPath
    let title: String
    var nextView: NavigationViews
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button(action: {
                navigationPath.path.append(nextView)
            }) {
                Text("EDIT")
                    .foregroundColor(.blue)
                    .padding()
                    .cornerRadius(10)
            }
        }
    }
}


struct ScrollablePDF: View {
    private struct ConditionSection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath
        
        var body: some View {
            Section(header: HeaderTitle(title: "Conditions", nextView: NavigationViews.medical)) {
                List(data.conditionData, id: \.id) { item in
                    HStack {
                        Text(item.condition)
                        Spacer()
                        Text(item.active ? "Active" : "Inactive")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private struct ExportButton: View {
        @Environment(NavigationPathWrapper.self) private var navigationPath
        @Environment(DataStore.self) private var data
        
        var body: some View {
            Button(action: {
                saveDataStore(dataStore: data)
                navigationPath.path.append(NavigationViews.export)
            }) {
                Text("Share")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        
        func saveDataStore(dataStore: DataStore) {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(dataStore)
                // You can also use UserDefaults if the data is small enough, but file storage is recommended for larger data
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let pathWithFilename = documentDirectory.appendingPathComponent("DataStore.json")
                    try data.write(to: pathWithFilename)
                    print("successfully stored")
                }
            } catch {
                print("Failed to save DataStore: \(error)")
            }
        }
    }
    
    private struct SurgerySection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath
        
        var body: some View {
            Section(header: HeaderTitle(title: "Surgical History", nextView: NavigationViews.surgical)) {
                List(data.surgeries, id: \.id) { item in
                    HStack {
                        Text(item.surgeryName)
                        Spacer()
                        Text(item.date)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private struct MedicationSection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath
        
        var body: some View {
            let medicationData = data.medicationData
            Section(header: HeaderTitle(title: "Medications", nextView: NavigationViews.medication)) {
                ForEach(Array(medicationData), id: \.self) { medicationInstance in
                    List {
                        HStack {
                            Text(medicationInstance.type.localizedDescription)
                            Spacer()
                            Text("\(medicationInstance.dosage.localizedDescription) - \(medicationInstance.schedule.frequency.description)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    private struct ChiefComplaint: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath
        
        var body: some View {
            Section(header: HeaderTitle(title: "Chief Complaint", nextView: NavigationViews.concern)) {
                Text(data.chiefComplaint)
            }
        }
    }
    
    private struct PatientInfo: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath
        @Environment(FHIRStore.self) private var fhirStore
        
        var body: some View {
            Section(header: HeaderTitle(title: "Patient Information", nextView: NavigationViews.patient)) {
                List {
                    HStack {
                        Text("Name:")
                        Spacer()
                        Text(data.generalData.name)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Date of Birth:")
                        Spacer()
                        Text(data.generalData.birthdate)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Age")
                        Spacer()
                        Text(data.generalData.age)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Sex")
                        Spacer()
                        Text(data.generalData.sex)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private struct AllergySection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath
        
        var body: some View {
            Section(header: HeaderTitle(title: "Allergies", nextView: NavigationViews.allergies)) {
                @Bindable var data = data
                List($data.allergyData, id: \.id) { $item in
                    HStack {
                        Text(item.allergy)
                        Spacer()
                        let reactionsString = concatenate(strings: item.reaction)
                        if !reactionsString.isEmpty {
                            Text(reactionsString)
                                .foregroundColor(.secondary)
                        } else {
                            Text("No reactions")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        
        func concatenate(strings: [ReactionItem]) -> String {
            let names = strings.map { $0.reaction }
            return names.joined(separator: ", ")
        }
    }
    
    private struct MenstrualSection: View {
        @Environment(DataStore.self) private var data
        
        var body: some View {
            Section(header: Text("Menstrual History")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Start Date:")
                        Spacer()
                        Text(data.menstrualHistory.startDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("End Date:")
                        Spacer()
                        Text(data.menstrualHistory.endDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Additional Details:")
                        Spacer()
                        Text(data.menstrualHistory.additionalDetails)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private struct SmokingSection: View {
        @Environment(DataStore.self) private var data
        
        var body: some View {
            Section(header: Text("Smoking History")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Currently Smoking:")
                        Spacer()
                        Text(data.smokingHistory.currentlySmoking ? "Yes" : "No")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Smoked in the Past:")
                        Spacer()
                        Text(data.smokingHistory.smokedInThePast ? "Yes" : "No")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Additional Details:")
                        Spacer()
                        Text(data.smokingHistory.additionalDetails)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(ReachedEndWrapper.self) private var end
    
    
    var body: some View {
        VStack {
            Form {
                PatientInfo()
                ChiefComplaint()
                ConditionSection()
                SurgerySection()
                MedicationSection()
                AllergySection()
                if data.generalData.sex == "Female" {
                    MenstrualSection()
                }
                SmokingSection()
            }
            
            ExportButton()
                .padding()
        }
            .navigationTitle("Patient Form")
            .task {
                end.reachedEnd = true
            }
    }
}
