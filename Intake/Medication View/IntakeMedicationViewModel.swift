//
//  IntakeMedicationViewModel.swift
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
import class ModelsR4.MedicationRequest
import Spezi
import SpeziFHIR
import SpeziMedication
import SwiftUI

@Observable
class IntakeMedicationSettingsViewModel: Module, MedicationSettingsViewModel, CustomStringConvertible {
    var medicationInstances: Set<IntakeMedicationInstance> = []
    let medicationOptions: Set<IntakeMedication>

    var description: String {
        guard !medicationInstances.isEmpty else {
            return "No Medications"
        }

        return medicationInstances
            .map { medicationInstance in
                let scheduleDescription: String
                switch medicationInstance.schedule.frequency {
                case let .regularDayIntervals(dayInterval):
                    scheduleDescription = "RegularDayIntervals: \(dayInterval)"
                case let .specificDaysOfWeek(weekdays):
                    scheduleDescription = "SpecificDaysOfWeek: \(weekdays)"
                case .asNeeded:
                    scheduleDescription = "AsNeeded"
                }

                return "\(medicationInstance.type.localizedDescription) - \(medicationInstance.dosage.localizedDescription) - \(scheduleDescription)"
            }
            .joined(separator: ", ")
    }

    init(existingMedications: [FHIRResource]) { // swiftlint:disable:this function_body_length
        self.medicationOptions = [
            IntakeMedication(
                localizedDescription: "Hydrochlorothiazide 25 MG Oral Tablet",
                dosages: [
                    IntakeDosage(localizedDescription: "25 MG")
                ]
            ),
            IntakeMedication(
                localizedDescription: "Acetaminophen 160 MG Chewable Tablet",
                dosages: [
                    IntakeDosage(localizedDescription: "160 MG")
                ]
            ),
            IntakeMedication(
                localizedDescription: "Fexofenadine hydrochloride 30 MG Oral Tablet",
                dosages: [
                    IntakeDosage(localizedDescription: "30 MG")
                ]
            ),
            IntakeMedication(
                localizedDescription: "NDA020800 0.3 ML Epinephrine 1 MG/ML Auto-Injector",
                dosages: [
                    IntakeDosage(localizedDescription: "0.3ML / 1 MG/ML")
                ]
            )
        ]

        var foundMedications: [IntakeMedicationInstance] = []
        if !existingMedications.isEmpty {
            for medication in existingMedications {
                for option in medicationOptions where option.localizedDescription == medication.displayName {
                        var medSchedule: SpeziMedication.Schedule
                        let medRequest = medicationRequest(resource: medication)
                        if case .boolean(let asNeeded) = medRequest?.dosageInstruction?.first?.asNeeded {
                            if let asNeededbool = asNeeded.value?.bool {
                                if asNeededbool {
                                    medSchedule = SpeziMedication.Schedule(frequency: .asNeeded)
                                } else {
                                    let intValue: Int
                                    let interval = medRequest?.dosageInstruction?.first?.timing?.repeat?.period?.value?.decimal
                                    if let interval = interval {
                                        intValue = interval.int
                                    } else {
                                        continue
                                    }
                                    medSchedule = Schedule(frequency: .regularDayIntervals(intValue))
                                }
                                
                                guard let firstDosage = option.dosages.first else {
                                    continue
                                }

                                let intakeMedicationInstance = IntakeMedicationInstance(
                                    type: option,
                                    dosage: firstDosage,
                                    schedule: medSchedule
                                )
                                foundMedications.append(intakeMedicationInstance)
                            }
                        }
                }
            }
            self.medicationInstances = Set(foundMedications)
        }
    }
    func persist(medicationInstances: Set<IntakeMedicationInstance>) async throws {
        self.medicationInstances = medicationInstances
    }

    func medicationRequest(resource: FHIRResource) -> MedicationRequest? {
        guard case let .r4(resource) = resource.versionedResource,
              let medicationRequest = resource as? ModelsR4.MedicationRequest else {
            return nil
        }
        return medicationRequest
    }
}

extension Decimal {
    var int: Int {
        let intVal = NSDecimalNumber(decimal: self).intValue  // swiftlint:disable:this legacy_objc_type
        return intVal
    }
}
