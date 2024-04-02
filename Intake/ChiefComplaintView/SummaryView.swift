//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

struct ComplaintForm: View {
    @Binding var chiefComplaint: String
    
    
    var body: some View {
        Form {
            Section(header: Text("Here is a summary of the Primary Concern")) {
                TextField("Primary Concern", text: $chiefComplaint, axis: .vertical)
            }
        }
        .navigationTitle("Primary Concern")
    }
}


struct SummaryView: View {
    @Binding var chiefComplaint: String
    @Environment(NavigationPathWrapper.self) private var navigationPath

    
    var body: some View {
        ZStack {
            VStack {
                ComplaintForm(chiefComplaint: $chiefComplaint)
                
                Spacer(minLength: 62)
            }
            
            VStack {
                Spacer()
                
                SubmitButton(nextView: NavigationViews.medical)
                    .padding()
            }
        }
    }
}
