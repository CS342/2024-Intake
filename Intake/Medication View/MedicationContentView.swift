//
//  MedicationContentView.swift
//  Intake
//
//  Created by Kate Callon on 2/18/24.
//
//
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

struct MedicationContentView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(DataStore.self) private var data
    @State private var presentSettings = false

    @State private var medicationSettingsViewModel: IntakeMedicationSettingsViewModel?

    var body: some View {
        VStack {
            if let medicationSettingsViewModel {
                MedicationSettings(allowEmtpySave: true, medicationSettingsViewModel: medicationSettingsViewModel) {
                    data.medicationData = medicationSettingsViewModel.medicationInstances
                    navigationPath.path.append(NavigationViews.allergies)
                }
                        .navigationTitle("Medication Settings")
            } else {
                ProgressView()
            }
        }
            .task {
                let patientMedications = fhirStore.llmMedications
                self.medicationSettingsViewModel = IntakeMedicationSettingsViewModel(existingMedications: patientMedications)
            }
    }
    
    init() {}
}

#Preview {
    MedicationContentView()
}
