//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct LoadLastButton: View {
    @Binding var navigationPath: NavigationPath
    @Binding var disabled: Bool
    @Environment(DataStore.self) private var data
    
    
    var body: some View {
        Button(action: {
            let fetchData = loadDataStore()
            if let loadedData = fetchData {
                data.allergyData = loadedData.allergyData
                data.generalData = loadedData.generalData
                data.surgeries = loadedData.surgeries
                data.conditionData = loadedData.conditionData
                data.menstrualHistory = loadedData.menstrualHistory
                data.smokingHistory = loadedData.smokingHistory
                data.chiefComplaint = loadedData.chiefComplaint
                data.surgeriesLoaded = loadedData.surgeriesLoaded
                data.medicationData = loadedData.medicationData
                navigationPath.append(NavigationViews.pdfs)
            }
        }) {
            Text("Load Latest Form")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding()
                .background(disabled ? Color.blue.opacity(0.5) : Color.blue)
                .cornerRadius(10)
        }
        .disabled(disabled)
    }
    
    func loadDataStore() -> DataStore? {
        let decoder = JSONDecoder()
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFilename = documentDirectory.appendingPathComponent("DataStore.json")
            if let data = try? Data(contentsOf: pathWithFilename) {
                do {
                    let dataStore = try decoder.decode(DataStore.self, from: data)
                    print("successfully loaded")
                    return dataStore
                } catch {
                    print("Failed to load DataStore: \(error)")
                }
            }
        }
        return nil
    }
}
