//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziFirebaseAccount
import SwiftUI

@Observable
class NavigationPathWrapper {
    var path = NavigationPath()
}

struct PatientData: Codable {
    var name: String
    var birthdate: String
    var age: String
    var sex: String
}

struct ReactionItem: Identifiable, Codable {
    var id = UUID()
    var reaction: String
}


struct AllergyItem: Identifiable, Equatable, Codable {
    let id = UUID()
    var allergy: String
    var reaction: [ReactionItem]
    
    static func == (lhs: AllergyItem, rhs: AllergyItem) -> Bool {
        lhs.allergy == rhs.allergy
    }
}

struct MedicalHistoryItem: Identifiable, Equatable, Codable {
    var id = UUID()
    var condition: String
    var active: Bool
}


struct MenstrualHistoryItem: Codable {
    var startDate: Date
    var endDate: Date
    var additionalDetails: String
}

struct SmokingHistoryItem: Codable {
    var packYears: Double
    var additionalDetails: String
}

struct SurgeryItem: Identifiable, Equatable, Codable {
    var id = UUID()
    var surgeryName: String = ""
    var date: String = ""
    var endDate: String = ""
    var status: String = ""
    var location: String = ""
    var notes: [String] = []
    var bodySites: [String] = []
    var complications: [String] = []
}


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
    var smokingHistory = SmokingHistoryItem(packYears: 0.0, additionalDetails: "")
}

@Observable
class ReachedEndWrapper {
    var reachedEnd = false
    var surgeriesLoaded = false
}

@Observable
class LoadedWrapper {
    var conditionData = false
    var allergyData = false
}

@main
struct Intake: App {
    @UIApplicationDelegateAdaptor(IntakeDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false

    let navigationPath = NavigationPathWrapper()
    let data = DataStore()
    let reachedEnd = ReachedEndWrapper()
    let loaded = LoadedWrapper()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if completedOnboardingFlow {
                    HomeView()
                } else {
                    EmptyView()
                }
            }
                .sheet(isPresented: !$completedOnboardingFlow) {
                    OnboardingFlow()
                }
                .testingSetup()
                .spezi(appDelegate)
                .environment(navigationPath)
                .environment(data)
                .environment(reachedEnd)
                .environment(loaded)
        }
    }
}
