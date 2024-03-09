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


struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 2)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom)
            }
        }
    }
}

struct SocialHistoryQuestionView: View {
    struct SectionHeader: View {
        let title: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
            }
        }
    }
    
    private var menstrualCycleButtons: some View {
        VStack {
            Button(action: {
                isSelectingStartDate = true
            }) {
                HStack {
                    Text("Select your last period's start date")
                    Spacer() // Add Spacer here for white space
                    Image(systemName: "calendar")
                        .accessibilityLabel(Text("START_CALENDAR"))
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Spacer().frame(height: 16)
            
            Button(action: {
                isSelectingEndDate = true
            }) {
                HStack {
                    Text("Select your last period's end date")
                    Spacer()
                    Image(systemName: "calendar")
                        .accessibilityLabel(Text("END_CALENDAR"))
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
    
    private var menstrualCycleInformationSection: some View {
        Group {
//            Section(header: Text("Menstrual Information").foregroundColor(.gray)) {
//                menstrualCycleButtons
//            }
            Section(header: Text("Additional Symptoms")) {
                @Bindable var data = data
                TextField("Ex: Heavy bleeding on second day, fatigue...", text: $data.menstrualHistory.additionalDetails)
                
            }
            if shouldDisplayResponses {
                Section(header: Text("Your Responses").foregroundColor(.gray)) {
                    VStack(alignment: .leading) {
                        Text("Start Date: \(formatDate(startDate))")
                        Text("End Date: \(formatDate(endDate))")
                        if !additionalDetails.isEmpty {
                            Text("Symptoms: \(additionalDetails)")
                        }
                    }
                }
            }
        }
    }
    @Environment(DataStore.self) private var data
    
    @State private var dateString: String = ""
    @State private var additionalDetails: String = ""
    @State private var isFemale = false
    @State private var showMaleSlide = false
    @State private var healthStore = HKHealthStore()
    
    @State private var isSelectingStartDate = false
    @State private var isSelectingEndDate = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var lastPeriodDate: Date?
    
    @Environment(NavigationPathWrapper.self) private var navigationPath
    
    
    private var shouldDisplayResponses: Bool {
        !additionalDetails.isEmpty || startDate != Date() || endDate != Date()
    }
    
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 0
        return formatter
    }()
    
    var body: some View {
        NavigationView { // swiftlint:disable:this closure_body_length
            VStack { // swiftlint:disable:this closure_body_length
                Form {
                    menstrualCycleInformationSection
                }
                .navigationTitle("Social History")
                .onAppear {
                    fetchHealthKitData()
                }
                .sheet(isPresented: $isSelectingStartDate, content: {
                    VStack {
                        DatePicker("Select Start Date", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .onChange(of: startDate) { newDate in
                                data.menstrualHistory.endDate = startDate
                                }
                        
                        Button("Save") {
                            lastPeriodDate = startDate
                            isSelectingStartDate = false
                        }
                    }
                })
                .sheet(isPresented: $isSelectingEndDate, content: {
                    VStack {
                        DatePicker("Select End Date", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .onChange(of: endDate) { newDate in
                                data.menstrualHistory.endDate = newDate
                                }
                        
                        Button("Save") {
                            isSelectingEndDate = false
                        }
                    }
                })
                Spacer()
                
                SubmitButton(nextView: NavigationViews.smoking)
                    .padding()
                
                /*Button(action: {
                    data.menstrualHistory?.startDate = startDate
                    data.menstrualHistory?.endDate = endDate
                    data.menstrualHistory?.additionalDetails = additionalDetails
                    
                    navigationPath.path.append(NavigationViews.smoking)
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()*/
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
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
    }
}
