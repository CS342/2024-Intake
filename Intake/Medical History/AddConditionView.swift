//
//  AddConditionView.swift
//  Intake
//
//  Created by Akash Gupta on 2/19/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI
import SpeziFHIR

struct AddConditionView: View {
    @State private var conditionName: String = ""
    @State private var isActive: Bool?

    var body: some View {
           NavigationView {
               VStack(alignment: .leading, spacing: 20) {
                   TextField("Condition Name", text: $conditionName)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding([.horizontal, .top])

                   // Active/Inactive buttons
                   HStack {
                       Button(action: {
                           self.isActive = true
                       }) {
                           Text("Active")
                               .foregroundColor(isActive == true ? .white : .blue)
                               .padding()
                               .background(isActive == true ? Color.blue : Color.clear)
                               .cornerRadius(10)
                       }
                       Button(action: {
                           self.isActive = false
                       }) {
                           Text("Inactive")
                               .foregroundColor(isActive == false ? .white : .blue)
                               .padding()
                               .background(isActive == false ? Color.blue : Color.clear)
                               .cornerRadius(10)
                       }
                   }
                   .frame(maxWidth: .infinity)
                   .padding(.horizontal)

                   Spacer() // Pushes everything to the top

                   Button(action: {
                       // saveCondition()
                   }) {
                       Text("Save")
                           .foregroundColor(.white)
                           .padding()
                           .frame(maxWidth: .infinity)
                           .background(isActive != nil ? Color.blue : Color.gray)
                           .cornerRadius(10)
                   }
                   .disabled(isActive == nil)
                   .padding(.horizontal)
               }
               .navigationBarTitle(Text("Add Condition").font(.largeTitle))
               .navigationBarTitleDisplayMode(.inline)
           }
    }

    func saveCondition() {
        print("Condition Saved: \(conditionName), Active Status: \(String(describing: isActive))")
    }
}

#Preview {
    AddConditionView()
        .previewWith {
            FHIRStore()
        }
}
