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
        VStack {
            Text("Primary Concern")
                .font(.title)
                .padding(50)
            Text("Here is a summary of your primary concern:")
            TextField(
                "Summary",
                text: $chiefComplaint,
                axis: .vertical
            )
                .border(.secondary)
                .textFieldStyle(.roundedBorder)
                .padding()
                .multilineTextAlignment(.center)
            Button(action: {}, label: {
                Text("Submit")
            })
//            Button(action: { navigationPath.append(NavigationViews.allergies) }, label: {
//                Text("Submit")
//            })
        }
        .navigationTitle("Summary")
    }
    
    init(chiefComplaint: String) {
        self.chiefComplaint = chiefComplaint
    }
}
