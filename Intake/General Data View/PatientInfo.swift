////
////  SwiftUIView.swift
////  Intake
////
////  Created by Nina Boord on 3/9/24.
////
// This source file is part of the Intake based on the Stanford Spezi Template Medication project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
import SpeziFHIR
import SwiftUI

// swiftlint:disable type_contents_order
// Again, no matter the order of these variables, there is still issues with type_contents_order. It was necessary to just disable this.
struct PatientInfo: View {
    @State private var fullName: String = ""
    @State private var firstName: String = ""
    @State private var birthdate: String = ""
    @State private var gender: String = "female"
    @State private var sexOption: String = ""
    @State private var birthdateDateFormat = Date()
    
    @Environment(DataStore.self) private var data
    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(FHIRStore.self) private var fhirStore
    
    func calculateAge(from dobString: String, with format: String = "yyyy-MM-dd") -> String {
        if dobString.isEmpty {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        guard let birthDate = dateFormatter.date(from: dobString) else {
            return "Invalid date format or date string."
        }
        
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
        if let age = ageComponents.year {
            return "\(age)"
        } else {
            return "Could not calculate age"
        }
    }
    
    func getValue(forKey key: String, from jsonString: String) -> String? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error: Cannot create Data from JSON string")
            return nil
        }
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                if key == "name" {
                    if let nameArray = dictionary[key] as? [[String: Any]], !nameArray.isEmpty {
                        let nameDict = nameArray[0]
                        if let family = nameDict["family"] as? String,
                           let givenArray = nameDict["given"] as? [String],
                           !givenArray.isEmpty {
                            let given = givenArray.joined(separator: " ")
                            
                            return "\(given) \(family)"
                        }
                    }
                } else {
                    return dictionary[key] as? String
                }
            } else {
                print("Error: JSON is not a dictionary")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func getInfo(patient: FHIRResource, field: String) -> String {
        let jsonDescription = patient.jsonDescription
        
        if let infoValue = getValue(forKey: field, from: jsonDescription) {
            print("Info found: \(infoValue)")
            return infoValue
        }
        
        print("Key \(field) not found")
        return ""
    }
    
    var body: some View {
        @Bindable var data = data
        Form {
            Section(header: Text("Patient Information")) {
                HStack {
                    TextField("Full name", text: $data.generalData.name).accessibilityLabel("FULL NAME")
                    Spacer()
                }
                HStack {
                    DatePicker("Date of Birth:", selection: $birthdateDateFormat, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(DefaultDatePickerStyle()).accessibilityLabel("DATE OF BIRTH")
                }
                HStack {
                    let options = ["Female", "Male"]
                    Picker("Sex", selection: $sexOption) {
                        ForEach(options, id: \.self) { option in
                            Text(option).tag(option).accessibilityLabel("SEX")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            Spacer()
            if FeatureFlags.skipToScrollable {
                SubmitButtonWithAction(nextView: .pdfs, onButtonTap: {
                    updateData()
                }).accessibilityLabel("NEXT TO SCROLLABLE")
            } else {
                SubmitButtonWithAction(nextView: .medical, onButtonTap: {
                    updateData()
                }).accessibilityLabel("NEXT TO MEDICAL HISTORY")
            }
        }
        .task {
            loadData()
        }
    }
    
    @MainActor
    private func loadData() {
        if let patient = fhirStore.patient {
            fullName = getInfo(patient: patient, field: "name").filter { !$0.isNumber }
            birthdate = getInfo(patient: patient, field: "birthDate")
            gender = getInfo(patient: patient, field: "gender")
            let age = calculateAge(from: birthdate)
            
            // string to date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let dob = dateFormatter.date(from: birthdate) {
                birthdateDateFormat = dob
            }
            gender.capitalizeFirstLetter()
            sexOption = gender
            data.generalData = PatientData(name: fullName, birthdate: birthdate, age: age, sex: gender)
        }
    }
    
    private func updateData() {
        // date to string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        birthdate = dateFormatter.string(from: birthdateDateFormat)
        data.generalData.birthdate = birthdate
        let age = calculateAge(from: birthdate)
        data.generalData.sex = sexOption
        data.generalData.age = age
    }
}

extension String {
    mutating func capitalizeFirstLetter() {
        self = prefix(1).capitalized + dropFirst()
    }
}


struct PatientInfo_Previews: PreviewProvider {
    static var previews: some View {
        PatientInfo()
    }
}
