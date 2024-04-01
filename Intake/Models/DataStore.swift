//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


@Observable
class DataStore: Codable {
    var allergyData: [AllergyItem] = []
    var conditionData: [MedicalHistoryItem] = []
    var medicationData: Set<IntakeMedicationInstance> = []
    var surgeries: [SurgeryItem] = []
    var surgeriesLoaded = false
    var chiefComplaint: String = ""
    var generalData = PatientData(name: "", birthdate: "", age: "", sex: "")
    var menstrualHistory = MenstrualHistoryItem(startDate: Date(), endDate: Date(), additionalDetails: "")
    var smokingHistory = SmokingHistoryItem(hasSmokedOrSmoking: Bool(), currentlySmoking: Bool(), smokedInThePast: Bool(), additionalDetails: "")
}
