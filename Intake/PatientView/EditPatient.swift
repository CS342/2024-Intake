//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFHIR
import SwiftUI


struct EditPatientView: View {
    @Environment(DataStore.self) private var data
    @Environment(FHIRStore.self) private var fhirStore
    
    
    var body: some View {
        @Bindable var data = data
        
        ZStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $data.generalData.name)
                }
                Section(header: Text("Date of Birth")) {
                    TextField("Date of Birth", text: $data.generalData.birthdate)
                }
                Section(header: Text("Age")) {
                    TextField("Age", text: $data.generalData.age)
                }
                Section(header: Text("Sex")) {
                    TextField("Sex", text: $data.generalData.sex)
                }
            }
            
            VStack {
                Spacer()
                
                SubmitButton(nextView: NavigationViews.pdfs)
                    .padding()
            }
        }
    }
}


// #Preview {
//    EditPatientView()
// }
