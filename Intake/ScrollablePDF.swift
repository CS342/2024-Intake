//
//  ScrollablePDF.swift
//  Intake
//
//  Created by Akash Gupta on 2/28/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFHIR
import SwiftUI


struct HeaderTitle: View {
    @Environment(NavigationPathWrapper.self) private var navigationPath
    let title: String
    var nextView: NavigationViews

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button(action: {
                navigationPath.path.append(nextView)
            }) {
                Text("EDIT")
                    .foregroundColor(.blue)
                    .padding()
                    .cornerRadius(10)
            }
        }
    }
}

struct ScrollablePDF: View {
    private struct ConditionSection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Section(header: HeaderTitle(title: "Conditions", nextView: NavigationViews.medical)) {
                List(data.conditionData, id: \.id) { item in
                    HStack {
                    Text(item.condition)
                    Spacer()
                    Text(item.active ? "Active" : "Inactive")
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private struct ExportButton: View {
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Button(action: {
            }) {
                Text("Export to PDF")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
    }
    
    private struct SurgerySection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Section(header: HeaderTitle(title: "Surgical History", nextView: NavigationViews.surgical)) {
                List(data.surgeries, id: \.id) { item in
                    HStack {
                    Text(item.surgeryName)
                    Spacer()
                    Text(item.date ?? "")
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private struct MedicationSection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Section(header: HeaderTitle(title: "Medications", nextView: NavigationViews.medication)) {
                VStack(alignment: .leading) {
                    ForEach(Array(data.medicationData)) { item in
                        HStack {
                            Text(item.type.localizedDescription)
                                .padding(.leading)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    private struct ChiefComplaint: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Section(header: HeaderTitle(title: "Chief Complaint", nextView: NavigationViews.concern)) {
                Text(data.chiefComplaint)
            }
        }
    }
    
    private struct PatientInfo: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath
        var body: some View {
            Section(header: HeaderTitle(title: "Patient Information", nextView: NavigationViews.patient)) {
                List {
                    HStack {
                        Text("Name:")
                        Spacer()
                        Text(data.generalData.name)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Date of Birth:")
                        Spacer()
                        Text(data.generalData.birthdate)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Age")
                        Spacer()
                        Text(data.generalData.age)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Sex")
                        Spacer()
                        Text(data.generalData.sex)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private struct Allergy: View {
        @Environment(DataStore.self) private var data
        @State private var showingReaction = false
        @State private var selectedIndex = 0
        var body: some View {
            Section(header: HeaderTitle(title: "Allergy", nextView: NavigationViews.allergies)) {
                List {
                    ForEach(0..<data.allergyData.count, id: \.self) { index in
                        allergyButton(index: index)
                    }
                }
                .sheet(isPresented: $showingReaction, content: reactionPDFView)
            }
        }
        
        private func reactionPDFView() -> some View {
            ReactionPDF(index: selectedIndex, showingReaction: $showingReaction)
        }
            
        private func allergyButton(index: Int) -> some View {
            Button(action: {
                self.selectedIndex = index
                self.showingReaction = true
            }) {
                HStack {
                    Text(data.allergyData[index].allergy)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .accessibilityLabel(Text("DETAILS"))
                }
            }
        }
    }
    
    
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(ReachedEndWrapper.self) private var end

    
    var body: some View {
        VStack {
            Form {
                PatientInfo()
                ChiefComplaint()
                ConditionSection()
                SurgerySection()
                MedicationSection()
                Allergy()
            }
            .navigationTitle("Patient Form")
            .onAppear(perform: {
                end.reachedEnd = true
            })
            ExportButton()
                .padding()
        }
    }
}