//
//  SmokingHistory.swift
//  Intake
//
//  Created by Zoya Garg on 2/28/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct SmokingHistoryView: View {
    @State private var hasSmokedOrSmoking: Bool = false
    @State private var currentlySmoking: Bool = false
    @State private var smokedInThePast: Bool = false
    @State private var additionalDetails: String = ""
    @Environment(DataStore.self) private var data

    var body: some View {
        NavigationView {
            Form {
                initialSmokingQuestionSection
                
                if hasSmokedOrSmoking {
                    followUpQuestionsSection
                    additionalDetailsSection
                }
            }
            .navigationTitle("Social History")
            SubmitButton(nextView: NavigationViews.pdfs)
                .padding()
            .onDisappear {
                storeSmokingHistory()
            }
        }
    }

    private var initialSmokingQuestionSection: some View {
        Section(header: Text("Smoking Status").foregroundColor(.gray)) {
            Toggle("Have you smoked or are you currently smoking?", isOn: $hasSmokedOrSmoking)
        }
    }

    private var followUpQuestionsSection: some View {
        Section {
            Toggle("Are you currently smoking?", isOn: $currentlySmoking)
            Toggle("Have you smoked in the past?", isOn: $smokedInThePast)
        }
    }

    private var additionalDetailsSection: some View {
        Section(header: Text("Additional Details").foregroundColor(.gray)) {
            TextField("Ex: Smoked for 10 years, quit 5 years ago...", text: $additionalDetails)
        }
    }

    private func storeSmokingHistory() {
        // swiftlint:disable:next line_length
        data.smokingHistory = SmokingHistoryItem(hasSmokedOrSmoking: hasSmokedOrSmoking, currentlySmoking: currentlySmoking, smokedInThePast: smokedInThePast, additionalDetails: additionalDetails)
    }
}
