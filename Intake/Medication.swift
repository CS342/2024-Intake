//
//  Medication.swift
//  Intake
//
//  Created by Kate Callon on 2/5/24.
//

import Foundation
import SpeziMedication


struct ExampleMedication: Medication, Comparable {
    var localizedDescription: String
    var dosages: [ExampleDosage]
}
