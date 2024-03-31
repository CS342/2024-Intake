//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct HomeView: View {
    @State private var showSettings = false
    @State var isButtonDisabled = true

    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(DataStore.self) private var data
    
    
    var body: some View {
        @Bindable var navigationPath = navigationPath
        @Bindable var data = data
        
        NavigationStack(path: $navigationPath.path) {
            VStack {
                Spacer()
                
                homeLogo
                homeTitle
                
                Spacer()
                
                LoadLastButton(navigationPath: $navigationPath.path, disabled: $isButtonDisabled)
                    .padding(.bottom, 10)
                StartButton(navigationPath: $navigationPath.path)
                    .padding(.top, 10)
                
                Spacer()
            }
            .toolbar {
                SettingsButton(showSettings: $showSettings)
            }
            .navigationDestination(for: NavigationViews.self) { view in
                switch view {
                case .smoking: SmokingHistoryView()
                case .chat: LLMInteraction()
                case .allergies: AllergyList()
                case .surgical: SurgeryView()
                case .medical: MedicalHistoryView()
                case .medication: MedicationContentView()
                case .menstrual: SocialHistoryQuestionView()
                case .concern: SummaryView(chiefComplaint: $data.chiefComplaint)
                case .export: ExportView()
                case .patient: EditPatientView()
                case .pdfs: ScrollablePDF()
                case .inspect: InspectSurgeryView(surgery: $data.surgeries[data.surgeries.count - 1], isNew: true)
                case .newAllergy: EditAllergyView(item: $data.allergyData[data.allergyData.count - 1])
                case .general: PatientInfo()
                }
            }
        }
        .task {
            let fetchData = loadDataStore()
            
            if fetchData != nil {
                isButtonDisabled = false
            } else {
                isButtonDisabled = true
            }
        }
    }
    
    private var homeLogo: some View {
        Image(systemName: "waveform.path.ecg")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundColor(.blue)
            .accessibilityLabel(Text("HOME_LOGO"))
    }
    
    private var homeTitle: some View {
        Group {
            Text("ReForm")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text("AI-assisted medical intake")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
    
    
    func loadDataStore() -> DataStore? {
        let decoder = JSONDecoder()
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFilename = documentDirectory.appendingPathComponent("DataStore.json")
            if let data = try? Data(contentsOf: pathWithFilename) {
                do {
                    let dataStore = try decoder.decode(DataStore.self, from: data)
                    print("successfully loaded")
                    return dataStore
                } catch {
                    print("Failed to load DataStore: \(error)")
                }
            }
        }
        return nil
    }
}


#if DEBUG
#Preview {
    return HomeView()
        .previewWith(standard: IntakeStandard()) {}
}

#Preview {
    return HomeView()
        .previewWith(standard: IntakeStandard()) {}
}
#endif
