//
//  MedicationContentView.swift
//  Intake
//
//  Created by Kate Callon on 2/18/24.
//

import Foundation
import SpeziFHIR
import SpeziMedication
import SwiftUI

struct MedicationContentView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @EnvironmentObject private var navigationPath: NavigationPathWrapper
    @State private var presentSettings = false

    @State private var medicationSettingsViewModel: IntakeMedicationSettingsViewModel?
        
        init() {

        }
    
    
    var body: some View {
        VStack {
            if let medicationSettingsViewModel {
                MedicationSettings(allowEmtpySave: true, medicationSettingsViewModel: medicationSettingsViewModel){
                    self.navigationPath.append_item(item: NavigationViews.allergies)
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
}

#Preview {
    MedicationContentView()
}
