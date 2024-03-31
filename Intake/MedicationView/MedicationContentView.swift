// This source file is part of the Intake based on the Stanford Spezi Template Medication project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFHIR
import SpeziMedication
import SwiftUI

/// This view displays the medications in the patient's FHIR data, and allows them to add, update and delete their medications.
struct MedicationContentView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(DataStore.self) private var data
    @State private var presentSettings = false
    @State private var medicationSettingsViewModel: IntakeMedicationSettingsViewModel?
    
    
    var body: some View {
        VStack {
            if let medicationSettingsViewModel {
                MedicationSettings(allowEmptySave: true, medicationSettingsViewModel: medicationSettingsViewModel) {
                    if FeatureFlags.skipToScrollable {
                        data.medicationData = medicationSettingsViewModel.medicationInstances
                        navigationPath.path.append(NavigationViews.pdfs)
                    } else {
                        data.medicationData = medicationSettingsViewModel.medicationInstances
                        navigationPath.path.append(NavigationViews.allergies)
                    }
                }
                    .navigationTitle("Medications")
                    .navigationBarItems(trailing: NavigationLink(destination: MedicationLLMAssistant()) {
                        Image(systemName: "bubble")
                    })
            } else {
                ProgressView()
            }
        }
            // Task to initialize the MedicationSettingsViewModel with the patient's existing fhirStore medications.
            .task {
                let patientMedications = fhirStore.llmMedications
                self.medicationSettingsViewModel = IntakeMedicationSettingsViewModel(existingMedications: patientMedications)
                
                if !data.medicationData.isEmpty {
                    medicationSettingsViewModel?.medicationInstances = data.medicationData
                }
            }
            .onDisappear {
                data.medicationData = medicationSettingsViewModel?.medicationInstances ?? []
            }
    }
}


#Preview {
    MedicationContentView()
}
