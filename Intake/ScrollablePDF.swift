//
//  ScrollablePDF.swift
//  Intake
//
//  Created by Akash Gupta on 2/28/24.
//

import Foundation
import SpeziFHIR
import SwiftUI

var reachedEnd = false

struct ScrollablePDF: View {
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath

    var body: some View {
        Form {
            PatientInfo()
            ChiefComplaint()
            ConditionSection()
            SurgerySection()
            medicationsSection
            AllergySection()
//                    DatePicker("Last Menstrual Period", selection: $lastMenstrualPeriod, displayedComponents: .date)
//            smokingHistorySection
        }
        .navigationTitle("Patient Form")
        .onAppear(perform: {
            reachedEnd = true
        })
    }
        
    private var medicationsSection: some View {
        DetailSection(header: "Medications:", content: ["Oxycontin 20mg, twice a day", "Lisinopril 5mg, once a day"])
    }
        
        
//    private var smokingHistorySection: some View {
//        DetailRow(label: "Smoking History:", value: "20 pack years")
//    }
    
    private struct ConditionSection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Section(header: headerTitle) {
                VStack(alignment: .leading) {
                    ForEach(data.conditionData) { item in // Removed id: \.self since items are Identifiable
                        HStack {
                            Text(item.condition)
                                .padding(.leading)
                            Spacer()
                            Text(item.active ? "Active" : "Inactive" )
                        }
                    }
                }
            }
        }

        var headerTitle: some View { // Moved this inside ConditionSection
            HStack {
                Text("Conditions")
                Spacer()
                Button(action: {
                    navigationPath.path.append(NavigationViews.medical)
                }) {
                    Text("EDIT")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private struct SurgerySection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Section(header: headerTitle) {
                VStack(alignment: .leading) {
                    ForEach(data.surgeries) { item in
                        HStack {
                            Text(item.surgeryName)
                                .padding(.leading)
                            Spacer()
                            Text(item.date ?? "")
                        }
                    }
                }
            }
        }

        var headerTitle: some View {
            HStack {
                Text("Surgical History")
                Spacer()
                Button(action: {
                    navigationPath.path.append(NavigationViews.surgical)
                }) {
                    Text("EDIT")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private struct AllergySection: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Section(header: headerTitle) {
                VStack(alignment: .leading) {
                    ForEach(data.allergyData) { item in
                        Text(item.allergy)
                            .padding(.leading)
                        ForEach(item.reaction) { reaction in
                            Text(reaction.reaction)
                                .padding(.leading, 50)
                        }
                    }
                }
            }
        }

        var headerTitle: some View {
            HStack {
                Text("Allergies")
                Spacer()
                Button(action: {
                    navigationPath.path.append(NavigationViews.allergies)
                }) {
                    Text("EDIT")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private struct ChiefComplaint: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Section(header: headerTitle) {
                Text(data.chiefComplaint)
            }
        }

        var headerTitle: some View {
            HStack {
                Text("Chief Complaint")
                Spacer()
                Button(action: {
                    navigationPath.path.append(NavigationViews.concern)
                }) {
                    Text("EDIT")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private struct PatientInfo: View {
        @Environment(DataStore.self) private var data
        @Environment(NavigationPathWrapper.self) private var navigationPath

        var body: some View {
            Section(header: headerTitle) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Name:")
                            .bold()
                        Text(data.generalData.name)
                    }
                    HStack {
                        Text("Date of Birth:")
                            .bold()
                        Text(data.generalData.birthdate)
                    }
                    HStack {
                        Text("Age")
                            .bold()
                        Text(data.generalData.age)
                    }
                    HStack {
                        Text("Sex")
                            .bold()
                        Text(data.generalData.sex)
                    }
                }
            }
        }

        var headerTitle: some View {
            HStack {
                Text("Patient Information")
                Spacer()
                Button(action: {
                    navigationPath.path.append(NavigationViews.patient)
                }) {
                    Text("EDIT")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                }
            }
        }
    }
}


struct DetailSection: View {
    var header: String
    var content: [String]
    
        
    var body: some View {
        Section(header: headerTitle) {
            VStack(alignment: .leading) {
                ForEach(content, id: \.self) { item in
                    Text(item)
                        .padding(.leading)
                }
            }
        }
    }
    
    private var headerTitle: some View {
        HStack {
            Text(header)
            Spacer()
            EditButton()
        }
    }
}


#Preview {
    ScrollablePDF()
        .previewWith {
            FHIRStore()
        }
}
