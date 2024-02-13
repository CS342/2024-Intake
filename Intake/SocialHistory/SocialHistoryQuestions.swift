//
//  SocialHistoryQuestions.swift
//  Intake
//
//  Created by Zoya Garg on 2/4/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SwiftUI

struct SmokingSummaryView: View {
    let startDate: Date
    let endDate: Date
    let additionalDetails: String
    let totalPacksPerYear: Double

    var body: some View {
        VStack {
            Text("Thank you for completing Social History!")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom)

            Text("Your last period was from \(formatDate(startDate)) to \(formatDate(endDate))")
                .multilineTextAlignment(.center)
                .padding(.bottom)

            if !additionalDetails.isEmpty {
                Text("Additional details: \(additionalDetails)")
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }

            Text("Total calculated result for smoking: \(totalPacksPerYear, specifier: "%.2f") pack years")
                .multilineTextAlignment(.center)
                .padding(.bottom)

            Spacer()
        }
        .padding()
        .navigationBarTitle("Summary", displayMode: .inline) // Set the navigation bar title for the summary view
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct YesNoButtonView: View {
    @State private var daysPerYear: Double?
    @State private var packsPerDay: Double?
    @State private var totalPacksPerYear: Double = 0
    @State private var navigateToSummary = false

    var startDate: Date
    var endDate: Date
    var additionalDetails: String

    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 0
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Do you currently smoke or have you in the past?")
                .font(.title)
                .foregroundColor(.blue)

            // Question 1
            TextField("How many days a year do you smoke?", value: $daysPerYear, formatter: numberFormatter)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 8)
            
            Text("You can include decimal values (e.g., 0.25) for the number of packs per day.")
                .font(.caption)
                .foregroundColor(.gray)

            // Question 2
            TextField("How many packs do you smoke a day?", value: $packsPerDay, formatter: numberFormatter)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 8)
            
            
            Button("Submit") {
                    calculateTotalPacksPerYear()
                    navigateToSummary = true
            }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            
            // NOTE: Ask Zoya about deprecated NavigationLink -- replace with sheet? Integrate into main navigation stack?
            NavigationLink(
                destination: SmokingSummaryView(
                                                startDate: startDate,
                                                endDate: endDate,
                                                additionalDetails: additionalDetails,
                                                totalPacksPerYear: totalPacksPerYear
                                                ),
               isActive: $navigateToSummary
            ) {
                EmptyView()
            }
        }
            .padding()
    }
    
    func calculateTotalPacksPerYear() {
        let days = daysPerYear ?? 0
        let packs = packsPerDay ?? 0
        totalPacksPerYear = days * packs
    }
}

struct SocialHistoryQuestionView: View {
    struct SectionHeader: View {
        let title: String
        let subtitle: String

        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var menstrualCycleButtons: some View {
        VStack {
            Button(action: {
                isSelectingStartDate = true
            }) {
                HStack {
                    Text("Select approx. start date.")
                    Spacer() // Add Spacer here for white space
                    Image(systemName: "calendar")
                        .accessibilityLabel(Text("START_CALENDAR"))
                }
            }
            .buttonStyle(BorderlessButtonStyle())

            Spacer().frame(height: 16) // White space between buttons

            Button(action: {
                isSelectingEndDate = true
            }) {
                HStack {
                    Text("Select approx. end date.")
                    Spacer()
                    Image(systemName: "calendar")
                        .accessibilityLabel(Text("END_CALENDAR"))
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
    
    private var menstrualCycleInformationSection: some View {
        Section(header: SectionHeader(title: "Menstrual Cycle Information", subtitle: "Select the dates of your last period.")) {
            menstrualCycleButtons
            TextField("Optional symptoms: heavy bleeding, cramps, etc.", text: $additionalDetails)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
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
    
    @State private var daysPerYear: Double?
    @State private var packsPerDay: Double?
    @State private var totalPacksPerYear: Double = 0
    @State private var navigateToSummary = false

    // Passed parameters should not be within a function or closure

    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 0
        return formatter
    }()

    var body: some View {
        NavigationView {
            Form {
                menstrualCycleInformationSection
                Section {
                    NavigationLink(destination: YesNoButtonView(startDate: startDate, endDate: endDate, additionalDetails: additionalDetails)) {
                        Text("Next: Smoking History").foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Social History")
            .onAppear {
                fetchHealthKitData()
            }
            .sheet(isPresented: $isSelectingStartDate, content: {
                VStack {
                    DatePicker("Select Start Date", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    
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
                    
                    Button("Save") {
                        // Handle saving the end date here
                        isSelectingEndDate = false
                    }
                }
            })
        }
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
                
                // Fetch and auto-populate the last menstrual period date from HealthKit
                // Update the startDate and endDate variables accordingly
                
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
