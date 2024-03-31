//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKitOnFHIR
import ModelsR4
import OSLog
import PDFKit
import Spezi
import SpeziFHIR
import SpeziFHIRHealthKit
import SpeziHealthKit
import SpeziOnboarding
import SwiftUI


actor IntakeStandard: Standard, EnvironmentAccessible, HealthKitConstraint, OnboardingConstraint {
    enum IntakeStandardError: Error {
        case userNotAuthenticatedYet
    }

    @Dependency var fhirStore: FHIRStore

    @MainActor var useHealthKitResources = true
    private var samples: [HKSample] = []
    private let logger = Logger(subsystem: "Intake", category: "Standard")

    
    func add(sample: HKSample) async {
        samples.append(sample)
        if await useHealthKitResources {
            await fhirStore.add(sample: sample)
        }
    }

    func remove(sample: HKDeletedObject) async {
        samples.removeAll(where: { $0.id == sample.uuid })
        if await useHealthKitResources {
            await fhirStore.remove(sample: sample)
        }
    }

    @MainActor
    func loadHealthKitResources() async {
        await fhirStore.removeAllResources()

        for sample in await samples {
            await fhirStore.add(sample: sample)
        }

        useHealthKitResources = true
    }

    /// Stores the given consent form in the user's document directory with a unique timestamped filename.
    ///
    /// - Parameter consent: The consent form's data to be stored as a `PDFDocument`.
    func store(consent: PDFDocument) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = formatter.string(from: Date())

        guard let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logger.error("Could not create path for writing consent form to user document directory.")
            return
        }

        let filePath = basePath.appending(path: "consentForm_\(dateString).pdf")
        consent.write(to: filePath)
    }
}
