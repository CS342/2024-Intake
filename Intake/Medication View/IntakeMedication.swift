// This source file is part of the Intake based on the Stanford Spezi Medication Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziMedication

/// Describes the IntakeMedication struct which contains a localizedDescription (medication name) and a list of dosages.
struct IntakeMedication: Medication, Comparable, Codable {
    var localizedDescription: String
    var dosages: [IntakeDosage]
}
