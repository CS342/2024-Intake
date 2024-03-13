//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziMockWebService
import SwiftUI

enum NavigationViews: String {
    case allergies
    case surgical
    case medical
    case menstrual
    case smoking
    case medication
    case chat
    case concern
    case export
    case patient
    case pdfs
    case inspect
    case general
    case newAllergy
}

struct StartButton: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Button(action: {
            navigationPath.append(NavigationViews.general)
        }) {
            Text("Create New Form")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}

struct LoadLastButton: View {
    @Binding var navigationPath: NavigationPath
    @Binding var disabled: Bool
    @Environment(DataStore.self) private var data
    
    var body: some View {
        Button(action: {
            let fetchData = loadDataStore()
            if let loadedData = fetchData {
                data.allergyData = loadedData.allergyData
                data.generalData = loadedData.generalData
                data.surgeries = loadedData.surgeries
                data.conditionData = loadedData.conditionData
                data.menstrualHistory = loadedData.menstrualHistory
                data.smokingHistory = loadedData.smokingHistory
                data.chiefComplaint = loadedData.chiefComplaint
                data.surgeriesLoaded = loadedData.surgeriesLoaded
                data.medicationData = loadedData.medicationData
                navigationPath.append(NavigationViews.pdfs)
            }
        }) {
            Text("Load Latest Form")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding()
                .background(disabled ? Color.blue.opacity(0.5) : Color.blue)
                .cornerRadius(10)
        }
        .disabled(disabled)
    }
    
    func loadDataStore() -> DataStore? {
        let decoder = JSONDecoder()
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFilename = documentDirectory.appendingPathComponent("DataStore3.json")
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


struct SettingsButton: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        Button(
            action: {
                showSettings.toggle()
            },
            label: {
                Image(systemName: "gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                    .accessibilityLabel(Text("SETTINGS"))
            }
        )
    }
}

struct HomeView: View {
    static var accountEnabled: Bool {
        !FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding
    }
    
    @State private var presentingAccount = false
    @State private var showSettings = false
    @State var isButtonDisabled = true

    @Environment(NavigationPathWrapper.self) private var navigationPath
    @Environment(DataStore.self) private var data
    
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
                case .chat: LLMInteraction(presentingAccount: $presentingAccount)
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
        .sheet(isPresented: $presentingAccount) {
            AccountSheet()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .accountRequired(Self.accountEnabled) {
            AccountSheet()
        }
        .verifyRequiredAccountDetails(Self.accountEnabled)
        .onAppear {
            let fetchData = loadDataStore()
            if let loadedData = fetchData {
                isButtonDisabled = false
            } else {
                isButtonDisabled = true
            }
        }
    }
    
    func loadDataStore() -> DataStore? {
        let decoder = JSONDecoder()
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFilename = documentDirectory.appendingPathComponent("DataStore3.json")
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
    let details = AccountDetails.Builder()
        .set(\.userId, value: "lelandstanford@stanford.edu")
        .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))
    
    return HomeView()
        .previewWith(standard: IntakeStandard()) {
            IntakeScheduler()
            MockWebService()
            AccountConfiguration(building: details, active: MockUserIdPasswordAccountService())
        }
}

#Preview {
    CommandLine.arguments.append("--disableFirebase") // make sure the MockWebService is displayed
    return HomeView()
        .previewWith(standard: IntakeStandard()) {
            IntakeScheduler()
            MockWebService()
            AccountConfiguration {
                MockUserIdPasswordAccountService()
            }
        }
}
#endif
