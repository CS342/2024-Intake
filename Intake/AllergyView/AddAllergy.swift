// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFHIR
import SwiftUI

struct EditAllergyView: View {
    @Binding var item: AllergyItem
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let index = data.allergyData.firstIndex(of: item) ?? 0
            @Bindable var data = data
            
            ZStack {
                VStack {
                    TextField("Allergy Name", text: $data.allergyData[index].allergy)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding([.horizontal, .top])
                        .accessibilityLabel("Add Allergy Field")
                    
                    ReactionSectionView(index: index)
                    
                    Spacer(minLength: 62)
                }
                
                VStack {
                    Spacer()
                    
                    saveButton
                }
            }
        }
        .navigationBarTitle("Allergy")
    }
    
    private var saveButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Save")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.accent)
                .cornerRadius(8)
        }
            .padding()
    }
}
