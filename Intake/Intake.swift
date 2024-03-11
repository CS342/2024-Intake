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

struct PatientData {
    var name: String
    var birthdate: String
    var age: String
    var sex: String
}

@Observable
class DataStore {
    var allergyData: [AllergyItem] = []
    var conditionData: [MedicalHistoryItem] = []
    var medicationData: Set<IntakeMedicationInstance> = []
    var surgeries: [SurgeryItem] = []
    var surgeriesLoaded = false
    var chiefComplaint: String = ""
    var generalData = PatientData(name: "", birthdate: "", age: "", sex: "")
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
