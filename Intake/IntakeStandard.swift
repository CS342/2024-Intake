//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import FirebaseStorage
import HealthKitOnFHIR
import OSLog
import PDFKit
import Spezi
import SpeziAccount
import SpeziFHIR
import SpeziFHIRHealthKit
import SpeziFirebaseAccountStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziMockWebService
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI

actor IntakeStandard: Standard, EnvironmentAccessible, HealthKitConstraint, OnboardingConstraint, AccountStorageConstraint {
    enum IntakeStandardError: Error {
        case userNotAuthenticatedYet
    }

    private static var userCollection: CollectionReference {
        Firestore.firestore().collection("users")
    }

    @Dependency var fhirStore: FHIRStore

    @MainActor var useHealthKitResources = true
    private var samples: [HKSample] = []

    @Dependency var mockWebService: MockWebService?
    @Dependency var accountStorage: FirestoreAccountStorage?

    @AccountReference var account: Account

    private let logger = Logger(subsystem: "Intake", category: "Standard")

    private var userDocumentReference: DocumentReference {
        get async throws {
            guard let details = await account.details else {
                throw IntakeStandardError.userNotAuthenticatedYet
            }

            return Self.userCollection.document(details.accountId)
        }
    }

    private var userBucketReference: StorageReference {
        get async throws {
            guard let details = await account.details else {
                throw IntakeStandardError.userNotAuthenticatedYet
            }

            return Storage.storage().reference().child("users/\(details.accountId)")
        }
    }

    init() {
        if !FeatureFlags.disableFirebase {
            _accountStorage = Dependency(wrappedValue: FirestoreAccountStorage(storeIn: IntakeStandard.userCollection))
        }
    }

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

    func add(response: ModelsR4.QuestionnaireResponse) async {
        let id = response.identifier?.value?.value?.string ?? UUID().uuidString

        if let mockWebService {
            let jsonRepresentation = (try? String(data: JSONEncoder().encode(response), encoding: .utf8)) ?? ""
            try? await mockWebService.upload(path: "questionnaireResponse/\(id)", body: jsonRepresentation)
            return
        }

        do {
            try await userDocumentReference
                .collection("QuestionnaireResponse") // Add all HealthKit sources in a /QuestionnaireResponse collection.
                .document(id) // Set the document identifier to the id of the response.
                .setData(from: response)
        } catch {
            logger.error("Could not store questionnaire response: \(error)")
        }
    }

    private func healthKitDocument(id uuid: UUID) async throws -> DocumentReference {
        try await userDocumentReference
            .collection("HealthKit") // Add all HealthKit sources in a /HealthKit collection.
            .document(uuid.uuidString) // Set the document identifier to the UUID of the document.
    }

    func deletedAccount() async throws {
        // delete all user associated data
        do {
            try await userDocumentReference.delete()
        } catch {
            logger.error("Could not delete user document: \(error)")
        }
    }

    /// Stores the given consent form in the user's document directory with a unique timestamped filename.
    ///
    /// - Parameter consent: The consent form's data to be stored as a `PDFDocument`.
    func store(consent: PDFDocument) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = formatter.string(from: Date())

        guard !FeatureFlags.disableFirebase else {
            guard let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                logger.error("Could not create path for writing consent form to user document directory.")
                return
            }

            let filePath = basePath.appending(path: "consentForm_\(dateString).pdf")
            consent.write(to: filePath)

            return
        }

        do {
            guard let consentData = consent.dataRepresentation() else {
                logger.error("Could not store consent form.")
                return
            }

            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            _ = try await userBucketReference.child("consent/\(dateString).pdf").putDataAsync(consentData, metadata: metadata)
        } catch {
            logger.error("Could not store consent form: \(error)")
        }
    }

    func create(_ identifier: AdditionalRecordId, _ details: SignupDetails) async throws {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        try await accountStorage.create(identifier, details)
    }

    func load(_ identifier: AdditionalRecordId, _ keys: [any AccountKey.Type]) async throws -> PartialAccountDetails {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        return try await accountStorage.load(identifier, keys)
    }

    func modify(_ identifier: AdditionalRecordId, _ modifications: AccountModifications) async throws {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        try await accountStorage.modify(identifier, modifications)
    }

    func clear(_ identifier: AdditionalRecordId) async {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        await accountStorage.clear(identifier)
    }

    func delete(_ identifier: AdditionalRecordId) async throws {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        try await accountStorage.delete(identifier)
    }
}
