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
// import SpeziFHIR
// import SwiftUI
//
// struct PatientInfo: View {
//    @Environment(DataStore.self) private var data
//    @Environment(NavigationPathWrapper.self) private var navigationPath
//    @Environment(FHIRStore.self) private var fhirStore
//    
//    
//    @State private var fullName: String = ""
//    @State private var firstName: String = ""
//    @State private var dob: String = ""
//    @State private var gender: String = ""
//    
//    func calculateAge(from dobString: String, with format: String = "yyyy-MM-dd") -> String {
//        if dobString.isEmpty {
//            return ""
//        }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = format
//        
//        guard let birthDate = dateFormatter.date(from: dobString) else {
//            return "Invalid date format or date string."
//        }
//        
//        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
//        if let age = ageComponents.year {
//            return "\(age)"
//        } else {
//            return "Could not calculate age"
//        }
//    }
//    
//    func getValue(forKey key: String, from jsonString: String) -> String? {
//        guard let jsonData = jsonString.data(using: .utf8) else {
//            print("Error: Cannot create Data from JSON string")
//            return nil
//        }
//        
//        do {
//            if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//                if key == "name" {
//                    if let nameArray = dictionary[key] as? [[String: Any]], !nameArray.isEmpty {
//                        let nameDict = nameArray[0] // Accessing the first name object
//                        if let family = nameDict["family"] as? String,
//                           let givenArray = nameDict["given"] as? [String],
//                           !givenArray.isEmpty {
//                            let given = givenArray.joined(separator: " ") // Assuming there might be more than one given name
//                            
//                            return "\(given) \(family)"
//                        }
//                    }
//                } else {
//                    return dictionary[key] as? String
//                }
//            } else {
//                print("Error: JSON is not a dictionary")
//            }
//        } catch {
//            print("Error: \(error.localizedDescription)")
//        }
//        
//        return nil
//    }
//    
//    func getInfo(patient: FHIRResource, field: String) -> String {
//        let jsonDescription = patient.jsonDescription
//        
//        if let infoValue = getValue(forKey: field, from: jsonDescription) {
//            print("Info found: \(infoValue)")
//            return infoValue
//        }
//        
//        print("Key \(field) not found")
//        return ""
//    }
//    
//    
//    var body: some View {
//        Section(header: HeaderTitle(title: "Patient Information", nextView: NavigationViews.patient)) {
//            List {
//                HStack {
//                    Text("Name:")
//                    Spacer()
//                    Text(data.generalData.name)
//                        .foregroundColor(.secondary)
//                }
//                HStack {
//                    Text("Date of Birth:")
//                    Spacer()
//                    Text(data.generalData.birthdate)
//                        .foregroundColor(.secondary)
//                }
//                HStack {
//                    Text("Age")
//                    Spacer()
//                    Text(data.generalData.age)
//                        .foregroundColor(.secondary)
//                }
//                HStack {
//                    Text("Sex")
//                    Spacer()
//                    Text(data.generalData.sex)
//                        .foregroundColor(.secondary)
//                }
//            } .onAppear {
//                loadData()
//            }
//        }
//    }
//    
//    private func loadData() {
//        if let patient = fhirStore.patient {
//            fullName = getInfo(patient: patient, field: "name").filter { !$0.isNumber }
//            dob = getInfo(patient: patient, field: "birthDate")
//            gender = getInfo(patient: patient, field: "gender")
//            
//            let age = calculateAge(from: dob)
//            let nameString = fullName.components(separatedBy: " ")
//            
//            if let firstNameValue = nameString.first {
//                firstName = firstNameValue
//            } else {
//                print("First Name is empty")
//            }
//            
//            data.generalData = PatientData(name: fullName, birthdate: dob, age: age, sex: gender)
//        }
//    }
// }
//
//
// struct PatientInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        PatientInfo()
//    }
// }
