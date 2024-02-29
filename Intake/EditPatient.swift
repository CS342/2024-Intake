//
//  EditPatient.swift
//  Intake
//
//  Created by Akash Gupta on 2/29/24.
//

import Foundation
import SwiftUI


struct EditPatientView: View {
    @Environment(DataStore.self) private var data
    
    var body: some View {
        @Bindable var data = data
        VStack {
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
            SubmitButton(nextView: NavigationViews.pdfs)
        }
    }
}

//
// #Preview {
//    EditPatientView()
// }