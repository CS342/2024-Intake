//
//  MedicationView.swift
//  Intake
//
//  Created by Kate Callon on 2/5/24.
//

import Foundation
import SpeziMedication
import SwiftUI
import SpeziFHIR


struct MedicationView: View {
    @State private var presentSettings = false
    @Environment(FHIRStore.self) private var fhirStore
    
    private var medicationSettingsViewModel: ExampleMedicationSettingsViewModel {
            // Compute medication display names when accessing the view model
        let medicationDisplayNames = fhirStore.medications.map { $0.displayName }
            return ExampleMedicationSettingsViewModel(medicationDisplayNames: medicationDisplayNames)
        }

    var body: some View {
        VStack {
            Button("Show Settings") {
                presentSettings.toggle()
            }
            Text(medicationSettingsViewModel.description)
        }
            .sheet(isPresented: $presentSettings) {
                NavigationStack {
                    MedicationSettings(isPresented: $presentSettings, medicationSettingsViewModel: medicationSettingsViewModel)
                        .navigationTitle("Medication Settings")
                }
            }
    }
}

#Preview {
    MedicationView()
    .previewWith {
        FHIRStore()
    }
}

