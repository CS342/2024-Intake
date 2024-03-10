//
//  LLMFiltering.swift
//  Intake
//
//  Created by Akash Gupta on 3/8/24.
//

import Foundation
import SwiftUI
import SpeziLLM
import SpeziLLMOpenAI


struct LLMFiltering: View {
    private var LLMFiltering = true
    @LLMSessionProvider<LLMOpenAISchema> var session: LLMOpenAISession
    
    init(systemPrompt: String) {
        self._session = LLMSessionProvider(
            schema: LLMOpenAISchema(
                parameters: .init(
                    modelType: .gpt3_5Turbo,
                    systemPrompt: systemPrompt
                )
            )
        )
    }
    
    var body: some View {
        Button(action: {
            let newSurgery = SurgeryItem(surgeryName: "Surgery")
        }) {
            Image(systemName: "plus")
                .accessibilityLabel(Text("ADD_SURGERY"))
        }
    }
    
    func filter(surgeries: [String]) async -> [String] {
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
        
        let manualFilter = surgeries.filter { !self.containsAnyWords(item: $0.lowercased(), words: stopWords) }
        
        if !self.LLMFiltering {
            return manualFilter
        }
        
        do {
            return try await self.LLMFilter(names: manualFilter)
        } catch {
            print("Error filtering with LLM: \(error)")
            print("Returning manually filtered surgeries")
            return manualFilter
        }
    }
    
    func containsAnyWords(item: String, words: [String]) -> Bool {
        words.contains { item.contains($0) }
    }
    
    func LLMFilter(names: [String]) async throws -> [String] {
        let LLMResponse = try await self.queryLLM(names: names)
        
        let filteredNames = LLMResponse.components(separatedBy: ", ")
        let filteredSurgeries = names.filter { self.containsAnyWords(item: $0, words: filteredNames) }
        
        return filteredNames
    }
    
    func queryLLM(names: [String]) async throws -> String {
        var responseText = ""
        
        await MainActor.run {
            session.context.append(userInput: names.joined(separator: ", "))
        }
        for try await token in try await session.generate() {
            responseText.append(token)
        }
        
        return responseText
    }
    
    
    func filterSurgeries() async throws -> [SurgeryItem] {
        @Environment(DataStore.self) var data
        let filteredNames = try await self.LLMFilter(names: [])
        let filteredSurgeries = data.surgeries.filter { self.containsAnyWords(item: $0.surgeryName, words: filteredNames) }
        var cleaned = filteredSurgeries
        for index in cleaned.indices {
            let oldName = cleaned[index].surgeryName
            if let newName: String = filteredNames.first(where: { oldName.contains($0) }) {
                cleaned[index].surgeryName = newName
            }
        }
        return cleaned
    }
    
    func filterConditions() async throws -> [MedicalHistoryItem] {
        @Environment(DataStore.self) var data
        let filteredNames = try await self.LLMFilter(names: [])
        let filteredSurgeries = data.conditionData.filter { self.containsAnyWords(item: $0.condition, words: filteredNames) }
        var cleaned = filteredSurgeries
        for index in cleaned.indices {
            let oldName = cleaned[index].condition
            if let newName: String = filteredNames.first(where: { oldName.contains($0) }) {
                cleaned[index].condition = newName
            }
        }
        return cleaned
    }
}

