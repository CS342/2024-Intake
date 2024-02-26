//
//  IntakeMedicationInstance.swift
//  Intake
//
//  Created by Kate Callon on 2/17/24.
//

import Foundation
import SpeziMedication


struct IntakeMedicationInstance: MedicationInstance, MedicationInstanceInitializable {
    let id: UUID
    let type: IntakeMedication
    var dosage: IntakeDosage
    var schedule: Schedule
    
    
    init(type: IntakeMedication, dosage: IntakeDosage, schedule: Schedule) {
        self.id = UUID()
        self.type = type
        self.dosage = dosage
        self.schedule = schedule
    }
}
