//
//  Elements.swift
//  Intake
//
//  Created by Nick Riedman on 2/25/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct SubmitButton: View {
    @EnvironmentObject private var navigationPath: NavigationPathWrapper
    var nextView: NavigationViews
    
    var body: some View {
        Button(action: {
            // Save output to Firestore and navigate to next screen
            // Still need to save output to Firestore
            self.navigationPath.append_item(item: nextView)
        }) {
            Text("Submit")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}
