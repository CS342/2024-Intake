//
//  IntakeMedication.swift
//  Intake
//
//  Created by Kate Callon on 2/17/24.
//
//
// This source file is part of the Intake based on the Stanford Spezi Medication Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziMedication

struct IntakeMedication: Medication, Comparable, Codable {
    var localizedDescription: String
    var dosages: [IntakeDosage]
}
