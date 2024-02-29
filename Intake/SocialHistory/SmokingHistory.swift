//
//  SmokingHistory.swift
//  Intake
//
//  Created by Zoya Garg on 2/28/24.
//

import SwiftUI


struct SmokingHistoryView: View {
    @State private var daysPerYear: String = ""
    @State private var packsPerDay: String = ""
    @State private var packYears: Double = 0
    @State private var additionalDetails: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Smoking History").foregroundColor(.gray)) {
                        TextField("How many days a year do you smoke?", text: $daysPerYear)
                            .keyboardType(.decimalPad)
                            .onChange(of: daysPerYear) { _ in calculatePackYears() }
                            .padding(.bottom, 8)
                        
                        TextField("How many packs do you smoke a day?", text: $packsPerDay)
                            .keyboardType(.decimalPad)
                            .onChange(of: packsPerDay) { _ in calculatePackYears() }
                            .padding(.bottom, 8)
                    }
                    
                    Section(header: Text("Additional Details").foregroundColor(.gray)) {
                        TextField("Ex: Smoked for 10 years, quit 5 years ago...", text: $additionalDetails)
                    }
                    
                    // This section will automatically update when values are entered
                    Section(header: Text("Your Responses").foregroundColor(.gray)) {
                        Text("Pack years: \(packYears, specifier: "%.2f")")
                        if !additionalDetails.isEmpty {
                            Text("Additional details: \(additionalDetails)")
                        }
                    }
                }
                .navigationTitle("Social History")
                
                // The Submit button can remain for explicit submission, if required
                Button("Submit") {
                    calculatePackYears()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    func calculatePackYears() {
        let days = Double(daysPerYear) ?? 0
        let packs = Double(packsPerDay) ?? 0
        packYears = (days * packs) / 365
    }
}
