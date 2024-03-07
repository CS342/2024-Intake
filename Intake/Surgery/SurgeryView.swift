//
//  SurgeryView.swift
//  Intake
//
//  Created by Kate Callon on 2/6/24.
//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4
import SpeziFHIR
import SpeziLLM
import SpeziLLMOpenAI
import SwiftUI


// In the future: make this a class for easier pass by reference
struct SurgeryItem: Identifiable {
    var id = UUID()
    var surgeryName: String = ""
    var startDate: FHIRDate?
    var endDate: FHIRDate?
    var status: String?
    var location: String?
    var notes: [String] = []
    var bodySites: [String] = []
    var complications: [String] = []
}

struct AddSurgery: View {
    @Binding var surgeries: [SurgeryItem]
    @Environment(DataStore.self) var data
    @Environment(NavigationPathWrapper.self) var navigationPath
    
    var body: some View {
        Button(action: {
            let newSurgery = SurgeryItem(surgeryName: "Surgery")
            navigationPath.path.append(NavigationViews.inspect)
            data.surgeries.append(newSurgery)
        }) {
            Image(systemName: "plus")
                .accessibilityLabel(Text("ADD_SURGERY"))
        }
    }
}

struct InspectSurgeryView: View {
    @Binding var surgery: SurgeryItem
    
    var isNew: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Procedure")) {
                TextField("Surgery Name", text: $surgery.surgeryName)
            }
            // Date
            // Status
            // Location
            // Body Sites (if any)
            // Complications (if any)
            // Notes (if any)
        }
        .navigationBarTitle(isNew ? "New Surgery" : "Edit Surgery")
    }
}

struct SurgeryView: View {
    @Environment(FHIRStore.self) private var fhirStore
    @Environment(DataStore.self) private var data
    @Environment(LLMRunner.self) var runner
    
    @State private var addingNewSurgery = false
    
    private var LLMFiltering = true
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession
    
    var body: some View {
        @Bindable var data = data
        if data.surgeriesLoaded {
            VStack {
                surgeryForm
                SubmitButton(nextView: NavigationViews.medication)
                    .padding()
            }
            .navigationTitle("Surgical History")
            .navigationBarItems(trailing: AddSurgery(surgeries: $data.surgeries))
            .toolbar {
                EditButton()
            }
        } else {
            ProgressView()
                .task {
                    await self.getProcedures()
                }
        }
    }
    
    private var surgeryElements: some View {
        Group {
            @Bindable var data = data
            ForEach($data.surgeries) { $item in
                NavigationLink(destination: InspectSurgeryView(surgery: $item, isNew: false)) {
                    Label(item.surgeryName, systemImage: "arrowtriangle.right")
                        .labelStyle(.titleOnly)
                }
            }
            .onDelete(perform: delete)
        }
    }
    
    private var surgeryForm: some View {
        Form {
            @Bindable var data = data
            Section(header: Text("Please add your past surgeries")) {
                surgeryElements
            }
        }
    }
    
    init() {
        let systemPrompt = """
            You are a helpful assistant that filters lists of procedures. You will be given\
            an array of strings. Each string will be the name of a procedure, but we only want
            to keep the names of relevant surgeries.
        
            For example, if you are given the following list:
            Mammography (procedure), Certification procedure (procedure), Cytopathology\
            procedure, preparation of smear, genital source (procedure), Transplant of kidney\
            (procedure),
        
            you should return something like this:
            Transplant of kidney, Mammography.
        
            In your response, return only the name of the surgeries. Ignore words in parenthesis
            like (procedure) or (regime/treatment).
        
            Do not make anything up, and do not change the name of the surgeries under any
            circumstances. Thank you!
        """
        
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: systemPrompt
                )
            )
        )
    }

    func delete(at offsets: IndexSet) {
        data.surgeries.remove(atOffsets: offsets)
    }

    func getProcedures() async {
        let procedures = fhirStore.procedures

        for pro in procedures where !data.surgeries.contains(where: { $0.surgeryName == pro.displayName }) {
            let vrs = pro.versionedResource
            switch vrs {
            case .r4(let result as ModelsR4.Procedure):
                addNewProcedure(procedure: result)
            default:
                print("This recourse is not an r4 Proceure")
            }
        }
        
        data.surgeries = await self.filter(surgeries: data.surgeries)
        data.surgeriesLoaded = true
    }
    
    func addNewProcedure(procedure: ModelsR4.Procedure) {
        var newEntry = SurgeryItem()
        
        if let name = procedure.code {
            newEntry.surgeryName = name.coding?[0].display?.value?.string ?? "Unknown"
        }
        
        newEntry.status = self.getStatus(status: procedure.status)
        
        if let date = procedure.performed {
            newEntry = self.unpackDate(performed: date, surgery: newEntry)
        }
        
        if let location = procedure.location {
            newEntry.location = location.display?.value?.string ?? ""
        }
        
        if let notes = procedure.note {
            let stringNotes: [String?] = notes.map { $0.text.value?.string }
            newEntry.notes = stringNotes.compactMap { $0 }
        }
        
        if let bodySites = procedure.bodySite {
            let stringBodySites: [String?] = bodySites.map { $0.text?.value?.string }
            newEntry.bodySites = stringBodySites.compactMap { $0 }
        }
        
        if let complications = procedure.complication {
            let stringComplications: [String?] = complications.map { $0.text?.value?.string }
            newEntry.complications = stringComplications.compactMap { $0 }
        }
        
        data.surgeries.append(newEntry)
    }
    
    func getStatus(status: FHIRPrimitive<EventStatus>) -> String {
        switch status.value ?? EventStatus.unknown {
        case .completed: "Completed"
        case .inProgress: "In Progress"
        case .notDone: "Not Done"
        case .onHold: "On Hold"
        case .stopped: "Stopped"
        case .enteredInError: "Entered in Error"
        default: "Unknown"
        }
    }
    
    func unpackDate(performed: Procedure.PerformedX, surgery: SurgeryItem) -> SurgeryItem {
        var result = surgery
        switch performed {
        case .period(let period):
            result.startDate = period.start?.value?.date
            result.endDate = period.end?.value?.date
        case .dateTime(let dateTime):
            result.startDate = dateTime.value?.date
        default:
            print("No Date")
        }
        return result
    }
    
    // Filter procedures
    
    func filter(surgeries: [SurgeryItem]) async -> [SurgeryItem] {
        let stopWords = [
            "screen",
            "medication",
            "examination",
            "assess",
            "development",
            "notification",
            "clarification",
            "discussion ",
            "option",
            "review",
            "evaluation",
            "management",
            "consultation",
            "referral",
            "interpretation",
            "discharge",
            "certification",
            "preparation"
        ]
        
        var manualFilter = surgeries.filter { !self.containsAnyWords(item: $0.surgeryName.lowercased(), words: stopWords) }
        
        if !self.LLMFiltering {
            return manualFilter
        }
        
        do {
            return try await self.LLMFilter(surgeries: manualFilter)
        } catch {
            print("Error filtering with LLM: \(error)")
            print("Returning manually filtered surgeries")
            return manualFilter
        }
    }
    
    func containsAnyWords(item: String, words: [String]) -> Bool {
        words.contains { item.contains($0) }
    }
    
    func LLMFilter(surgeries: [SurgeryItem]) async throws -> [SurgeryItem] {
        let surgeryNames = surgeries.map { $0.surgeryName }
        
        var LLMResponse = try await self.queryLLM(surgeryNames: surgeryNames)
        
        var filteredNames = LLMResponse.components(separatedBy: ", ")
        var filteredSurgeries = surgeries.filter { self.containsAnyWords(item: $0.surgeryName, words: filteredNames) }
        
        
        print("FILTER: ")
        print(filteredNames)
        print("________________")
        
        print("BEFORE")
        print(surgeries)
        print("________________")
        
        print("AFTER")
        print(self.cleanSurgeryNames(surgeries: filteredSurgeries, filteredNames: filteredNames))
        print("________________")
        
        return self.cleanSurgeryNames(surgeries: filteredSurgeries, filteredNames: filteredNames)
    }
    
    func queryLLM(surgeryNames: [String]) async throws -> String {
        var responseText = ""
        
        await MainActor.run {
            session.context.append(userInput: surgeryNames.joined(separator: ", "))
        }
        for try await token in try await session.generate() {
            responseText.append(token)
        }
        
        return responseText
    }
    
    func cleanSurgeryNames(surgeries: [SurgeryItem], filteredNames: [String]) -> [SurgeryItem] {
        var cleaned = surgeries
        for index in cleaned.indices {
            let oldName = cleaned[index].surgeryName
            if let newName: String = filteredNames.first(where: { oldName.contains($0) }) {
                cleaned[index].surgeryName = newName
            }
        }
        return cleaned
    }
}

#Preview {
    SurgeryView()
        .previewWith {
            FHIRStore()
        }
}
