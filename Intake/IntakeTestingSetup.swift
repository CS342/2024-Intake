//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
import ModelsR4
import SpeziFHIR
import SpeziFHIRMockPatients
import SwiftUI

private struct IntakeAppTestingSetup: ViewModifier {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @Environment(FHIRStore.self) private var store

    func body(content: Content) -> some View {
        content
            .task {
                if FeatureFlags.skipOnboarding {
                    completedOnboardingFlow = true
                }
                if FeatureFlags.showOnboarding {
                    completedOnboardingFlow = false
                }
                if FeatureFlags.testPatient {
                          let bundles = await ModelsR4.Bundle.llmOnFHIRMockPatients
                          let firstMockPatient = bundles[3]
                          store.removeAllResources()
                          store.load(bundle: firstMockPatient)
                        }
            }
    }
}
extension View {
    func testingSetup() -> some View {
        self.modifier(IntakeAppTestingSetup())
    }
}
