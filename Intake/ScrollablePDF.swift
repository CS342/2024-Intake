//
//  ScrollablePDF.swift
//  Intake
//
//  Created by Akash Gupta on 2/28/24.
//

import Foundation
import SpeziFHIR
import SwiftUI

struct ScrollablePDF: View {
    @Environment(DataStore.self) private var data

    var body: some View {
        Form {
            patientInfo
            chiefComplaint
            ConditionSection()
            surgicalHistorySection
            medicationsSection
            allergiesSection
//                    DatePicker("Last Menstrual Period", selection: $lastMenstrualPeriod, displayedComponents: .date)
//            smokingHistorySection
        }
        .navigationTitle("Patient Form")
    }
        
    
    private var patientInfo: some View {
        Group {
            DetailSection(header: "Patient Information", content: ["Name: Akash Gupta", "Date of Birth: 01/08/2003", "Age: 21", "Sex: Male"])
        }
    }
    
    private var chiefComplaint: some View {
        DetailSection(header: "Chief Complaint:", content: ["I hurt my knee and it hurts a lot on the outside for the last 10 days..."])
    }
        
    private var surgicalHistorySection: some View {
        DetailSection(header: "Past Surgical History:", content: ["Appendectomy, 2005", "Left Femur Fracture Repair, 2012"])
    }
        
    private var medicationsSection: some View {
        DetailSection(header: "Medications:", content: ["Oxycontin 20mg, twice a day", "Lisinopril 5mg, once a day"])
    }
        
    private var allergiesSection: some View {
        DetailSection(header: "Allergies:", content: ["Peanuts - Anaphylactic Shock", "Penicillin - Rash"])
    }
        
//    private var smokingHistorySection: some View {
//        DetailRow(label: "Smoking History:", value: "20 pack years")
//    }
    
    private struct ConditionSection: View {
        @Environment(DataStore.self) private var data// Assuming DataStore contains 'conditionData'

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
                EditButton()
            }
        }
    }
    
}

//struct DetailRow: View {
//    var label: String
//    var value: String
//        
//    var body: some View {
//        HStack {
//            Text(label)
//            Spacer()
//            Text(value)
//        }
//    }
//}

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
