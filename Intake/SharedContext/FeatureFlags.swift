//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

/// A collection of feature flags for the Intake.
enum FeatureFlags {
    /// Skips the onboarding flow to enable easier development of features in the application and to allow UI tests to skip the onboarding flow.
    static let skipOnboarding = CommandLine.arguments.contains("--skipOnboarding")
    /// Always show the onboarding when the application is launched. Makes it easy to modify and test the onboarding flow without the need to manually remove the application or reset the simulator.
    static let showOnboarding = CommandLine.arguments.contains("--showOnboarding")
    /// Adds a test task to the schedule at the current time
    static let testSchedule = CommandLine.arguments.contains("--testSchedule")
    static let testPatient = CommandLine.arguments.contains("--testPatient")
    static let testAllergy = CommandLine.arguments.contains("--testAllergy")
    static let testMenstrual = CommandLine.arguments.contains("--testMenstrual")
    static let testSmoking = CommandLine.arguments.contains("--testSmoking")
    static let testMedication = CommandLine.arguments.contains("--testMedication")
    static let skipToScrollable = CommandLine.arguments.contains("--skipToScrollable")
    static let testCondition = CommandLine.arguments.contains("--testCondition")
    static let testSurgery = CommandLine.arguments.contains("--testSurgery")
}
