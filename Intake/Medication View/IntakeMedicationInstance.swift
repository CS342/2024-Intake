//
//  IntakeMedicationInstance.swift
//  Intake
//
//  Created by Kate Callon on 2/17/24.
//
//
// This source file is part of the Intake based on the Stanford Spezi Template Medication project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziMedication

// This defines an IntakeMedicationInstance which is composed of an id, an IntakeMedication type, a dosage, and a schedule. 
struct IntakeMedicationInstance: MedicationInstance, MedicationInstanceInitializable, Codable {
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
