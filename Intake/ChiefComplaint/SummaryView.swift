//
//  SummaryView.swift
//  Intake
//
//  Created by Nick Riedman on 2/2/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

struct SummaryView: View {
    @State var chiefComplaint: String
//    var navigationPath: NavigationPath
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Primary Concern")
                .font(.title)
                .padding(.top, 50)
            
            Text("Here is a summary of your primary concern:")
            
            TextEditor(text: $chiefComplaint)
                .frame(height: 150)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .padding(.horizontal)
            
            Button(action: {
                // Save output to Fhirstore and navigate to next screen
//                navigationPath.append(NavigationViews.allergies)
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    init(chiefComplaint: String) {
        self.chiefComplaint = chiefComplaint
    }
}
