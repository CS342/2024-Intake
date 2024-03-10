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

struct SkipButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Skip")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(8) // Add padding for better appearance
                .cornerRadius(8) // Round the corners
        }
        .buttonStyle(PlainButtonStyle()) // Remove button border
    }
}


struct SubmitButton: View {
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(ReachedEndWrapper.self) private var end
    var nextView: NavigationViews

    var body: some View {
        Button(action: {
            if end.reachedEnd {
                navigationPath.path.append(NavigationViews.pdfs)
            } else {
                navigationPath.path.append(nextView)
            }
        }) {
            Text("Next")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}
