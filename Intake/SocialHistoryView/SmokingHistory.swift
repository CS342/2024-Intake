// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI


struct SmokingHistoryView: View {
    @State private var hasSmokedOrSmoking = false
    @State private var currentlySmoking = false
    @State private var smokedInThePast = false
    @State private var additionalDetails: String = ""
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(ReachedEndWrapper.self) private var end

    
    var body: some View {
        ZStack {
            VStack {
                Form {
                    initialSmokingQuestionSection
                    
                    if hasSmokedOrSmoking {
                        followUpQuestionsSection
                        additionalDetailsSection
                    }
                }
                
                Spacer(minLength: 62)
            }
            
            VStack {
                Spacer()
                
                if FeatureFlags.skipToScrollable {
                    SubmitButton(nextView: NavigationViews.pdfs)
                        .padding()
                } else {
                    SubmitButton(nextView: NavigationViews.pdfs)
                        .padding()
                }
            }
        }
            .navigationTitle("Social History")
            .onDisappear {
                storeSmokingHistory()
            }
    }

    private var initialSmokingQuestionSection: some View {
        Section(header: Text("Smoking Status").foregroundColor(.gray)) {
            Toggle("Are you currently smoking or have you smoked in the past?", isOn: $hasSmokedOrSmoking)
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
        data.smokingHistory = SmokingHistoryItem(
            hasSmokedOrSmoking: hasSmokedOrSmoking,
            currentlySmoking: currentlySmoking,
            smokedInThePast: smokedInThePast,
            additionalDetails: additionalDetails
        )
    }
}
