//
//  MedicationInstance.swift
//  Intake
//
//  Created by Kate Callon on 2/5/24.
//

import Foundation
import SpeziMedication


struct ExampleMedicationInstance: MedicationInstance, MedicationInstanceInitializable {
    let id: UUID
    let type: ExampleMedication
    var dosage: ExampleDosage
    var schedule: Schedule
    
    
    init(type: ExampleMedication, dosage: ExampleDosage, schedule: Schedule) {
        self.id = UUID()
        self.type = type
        self.dosage = dosage
        self.schedule = schedule
    }
}
