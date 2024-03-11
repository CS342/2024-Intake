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
    struct YesNoButtonStyle: ButtonStyle {
        var isSelected: Bool
        
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding()
                .background(isSelected ? Color.blue : Color.white)
                .foregroundColor(isSelected ? .white : .blue)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
        }
    }
    
    
    @State private var hasSmoked: Bool? // swiftlint:disable:this discouraged_optional_boolean
    @State private var daysPerYear: String = ""
    @State private var packsPerDay: String = ""
    @State private var packYears: Double = 0
    @State private var additionalDetails: String = ""
    @Environment(DataStore.self) private var data
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    yesNoQuestionView
                    if hasSmoked == true {
                        smokingDetailsForm
                    }
                }
                Spacer()
                .onDisappear {
                    calculatePackYears()
                    data.smokingHistory = SmokingHistoryItem(packYears: packYears, additionalDetails: additionalDetails)
                }

                SubmitButton(nextView: NavigationViews.chat)
                    .padding()
            }
            .navigationTitle("Social History")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    private var yesNoQuestionView: some View {
        VStack {
            Text("Do you currently smoke or have you smoked in the past?")
                .foregroundColor(.gray)
                .padding()
            
            HStack {
                Button("Yes") {
                    hasSmoked = true
                }
                .buttonStyle(YesNoButtonStyle(isSelected: hasSmoked == true))

                Button("No") {
                    hasSmoked = false
                }
                .buttonStyle(YesNoButtonStyle(isSelected: hasSmoked == false))
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var smokingDetailsForm: some View {
        VStack {
            Form {
                Section(header: Text("Smoking History").foregroundColor(.gray)) {
                    TextField("How many days a year do you smoke?", text: $daysPerYear)
                        .keyboardType(.decimalPad)
                        .onChange(of: daysPerYear) { calculatePackYears() }
                        .padding(.bottom, 8)
                    
                    TextField("How many packs do you smoke a day?", text: $packsPerDay)
                        .keyboardType(.decimalPad)
                        .onChange(of: packsPerDay) { calculatePackYears() }
                        .padding(.bottom, 8)
                }
                Section(header: Text("Additional Details").foregroundColor(.gray)) {
                    TextField("Ex: Smoked for 10 years, quit 5 years ago...", text: $additionalDetails)
                }
                if hasSmoked == true {
                    Section(header: Text("Calculation").foregroundColor(.gray)) {
                        Text("Pack years: \(packYears, specifier: "%.2f")")
                    }
                }
                
                // The Submit button can remain for explicit submission, if required
                Button("Submit") {
                    calculatePackYears()
                }
                SubmitButton(nextView: NavigationViews.pdfs)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Social History")
        }
    }
    
    func calculatePackYears() {
        let days = Double(daysPerYear) ?? 0
        let packs = Double(packsPerDay) ?? 0
        packYears = (days * packs) / 365
    }
}
