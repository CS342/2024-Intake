// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation
import HealthKit
import SwiftUI


struct SocialHistoryQuestionView: View {
    @State private var additionalDetails: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var healthStore = HKHealthStore()
    @State private var isFemale = false
    @State private var showMaleSlide = false
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(DataStore.self) private var data
    
    
    var body: some View {
        if data.generalData.sex == "Female" {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("Menstrual Information").foregroundColor(.gray)) {
                            @Bindable var data = data
                            DatePicker("Last period's start date", selection: $startDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(DefaultDatePickerStyle())
                            
                            DatePicker("Last period's end date", selection: $endDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(DefaultDatePickerStyle())
                        }
                        
                        Section(header: Text("Additional Symptoms").foregroundColor(.gray)) {
                            @Bindable var data = data
                            TextField("Ex: Heavy bleeding on second day, fatigue...", text: $additionalDetails)
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
                        SubmitButton(nextView: NavigationViews.smoking)
                            .padding()
                    }
                }
            }
            .navigationTitle("Menstrual History")
            .task {
                startDate = data.menstrualHistory.startDate
                endDate = data.menstrualHistory.endDate
                additionalDetails = data.menstrualHistory.additionalDetails
            }
            .onDisappear {
                data.menstrualHistory = MenstrualHistoryItem(startDate: startDate, endDate: endDate, additionalDetails: additionalDetails)
            }
        }
    }
}
