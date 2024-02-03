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
    let chiefComplaint: String
    
    var body: some View {
        VStack {
            Text(chiefComplaint)
                .padding()
                .multilineTextAlignment(.center)
        }
        .navigationTitle("Summary")
    }
}
