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

class NavigationPathWrapper: ObservableObject {
    @Published var path = NavigationPath()
    
    func append_item(item: NavigationViews) {
        path.append(item)
    }
}

class DataStore: ObservableObject {
    @Published var allergyData: [AllergyItem] = []
    @Published var conditionData: [MedicalHistoryItem] = []
    @Published var medicationData: [MedicationItem] = []
    
    func addAllergy(item: AllergyItem) {
        allergyData.append(item)
    }
    
    func addCondition(item: MedicalHistoryItem) {
        conditionData.append(item)
    }
    
    func addMedication(item: MedicationItem) {
        medicationData.append(item)
    }
}


@main
struct Intake: App {
    @UIApplicationDelegateAdaptor(IntakeDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    
    let navigationPath = NavigationPathWrapper()
    let data = DataStore()
    
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
                .environmentObject(navigationPath)
                .environmentObject(data)
        }
    }
}
