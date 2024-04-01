//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct PatientData: Codable {
    var name: String
    var birthdate: String
    var age: String
    var sex: String
}

struct ReactionItem: Identifiable, Codable {
    var id = UUID()
    var reaction: String
}


struct AllergyItem: Identifiable, Equatable, Codable {
    var id = UUID()
    var allergy: String
    var reaction: [ReactionItem]
    
    static func == (lhs: AllergyItem, rhs: AllergyItem) -> Bool {
        lhs.allergy == rhs.allergy
    }
}

struct MedicalHistoryItem: Identifiable, Equatable, Codable {
    var id = UUID()
    var condition: String
    var active: Bool
}


struct MenstrualHistoryItem: Codable {
    var startDate: Date
    var endDate: Date
    var additionalDetails: String
}

struct SmokingHistoryItem: Codable {
    var hasSmokedOrSmoking: Bool
    var currentlySmoking: Bool
    var smokedInThePast: Bool
    var additionalDetails: String
}

struct SurgeryItem: Identifiable, Equatable, Codable {
    var id = UUID()
    var surgeryName: String = ""
    var date: String = ""
    var endDate: String = ""
    var status: String = ""
    var location: String = ""
    var notes: [String] = []
    var bodySites: [String] = []
    var complications: [String] = []
}
