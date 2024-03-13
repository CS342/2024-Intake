//
//  MenstrualHistory.swift
//  Intake
//
//  Created by Zoya Garg on 2/28/24.
//
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
    // do this ONLY in nav before this
    var body: some View {
        NavigationView {
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
                .navigationTitle("Social History")
                .task {
                    startDate = data.menstrualHistory.startDate
                    endDate = data.menstrualHistory.endDate
                    additionalDetails = data.menstrualHistory.additionalDetails
                }
                /*.task {
                    fetchHealthKitData()
                }*/
                .onDisappear {
                    data.menstrualHistory = MenstrualHistoryItem(startDate: startDate, endDate: endDate, additionalDetails: additionalDetails)
                }
                SubmitButton(nextView: NavigationViews.smoking)
                    .padding()
            }
        }
    }
    /* Show View based on DataStore ! */
    /*
    private func fetchHealthKitData() {
        let infoToRead = Set([HKObjectType.characteristicType(forIdentifier: .biologicalSex)].compactMap { $0 })
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: infoToRead)
                
                if let bioSex = try? healthStore.biologicalSex() {
                    DispatchQueue.main.async {
                        self.isFemale = getIsFemaleBiologicalSex(biologicalSex: bioSex.biologicalSex)
                        self.showMaleSlide = !self.isFemale
                    }
                }
            } catch {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func getIsFemaleBiologicalSex(biologicalSex: HKBiologicalSex) -> Bool {
        switch biologicalSex {
        case .female: return true
        case .male: return false
        case .other: return true
        case .notSet: return false
        @unknown default: return false
        }
    }*/
}
