//
//  IntakeMedication.swift
//  Intake
//
//  Created by Kate Callon on 2/17/24.
//

import Foundation
import SpeziMedication


struct IntakeMedication: Medication, Comparable {
    var localizedDescription: String
    var dosages: [IntakeDosage]
}
