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
    case social
    case medication
    case chat
}

struct HomeView: View {
    enum Tabs: String {
        case schedule
        case form
        case contact
        case mockUpload
        case summary
        case medicalHistory
        case allergyRecords
        case medications
        case surgeries
        case socialHistory
    }
    
    @ToolbarContentBuilder private var settingsToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(
                action: {
                    showSettings.toggle()
                },
                label: {
                    Image(systemName: "gear")
                        .accessibilityLabel(Text("SETTINGS"))
                }
            )
        }
    }
    
    static var accountEnabled: Bool {
        !FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding
    }

    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.schedule
    @State private var presentingAccount = false
    @State private var showSettings = false
    
    @EnvironmentObject private var navigationPath: NavigationPathWrapper
    
    var body: some View {
        NavigationStack(path: $navigationPath.path) { // swiftlint:disable:this closure_body_length
            VStack { // swiftlint:disable:this closure_body_length
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showSettings.toggle()
                    },
                    label: {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .accessibilityLabel(Text("SETTINGS"))
                    })
                    
                    .padding()
                }
                
                Spacer()
                
                Image(systemName: "waveform.path.ecg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                Text("ReForm")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text("AI-assisted medical intake")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    self.navigationPath.append_item(item: NavigationViews.chat)
                }) {
                    Text("Start")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            
            .navigationDestination(for: NavigationViews.self) { view in
                switch view {
                case .chat: LLMInteraction(presentingAccount: $presentingAccount)
                case .allergies: AllergyView()
                case .surgical: SurgeryView()
                case .medical: MedicalHistoryView()
                case .social: SocialHistoryQuestionView()
                case .medication: MedicationView()
                }
            }
        }
//        .environmentObject(navigationPath)
        
        
//        TabView(selection: $selectedTab) { // swiftlint:disable:this closure_body_length
//            ScheduleView(presentingAccount: $presentingAccount)
//                .tag(Tabs.schedule)
//                .tabItem {
//                    Label("SCHEDULE_TAB_TITLE", systemImage: "list.clipboard")
//                }
//            Contacts(presentingAccount: $presentingAccount)
//                .tag(Tabs.contact)
//                .tabItem {
//                    Label("CONTACTS_TAB_TITLE", systemImage: "person.fill")
//                }
//            if FeatureFlags.disableFirebase {
//                MockUpload(presentingAccount: $presentingAccount)
//                    .tag(Tabs.mockUpload)
//                    .tabItem {
//                        Label("MOCK_WEB_SERVICE_TAB_TITLE", systemImage: "server.rack")
//                    }
//            }
//            SocialHistoryQuestionView()
//                .tag(Tabs.socialHistory)
//                .tabItem {
//                    Label("Social History", systemImage: "person.line.dotted.person")
//                }
//            MedicalHistoryView()
//                .tag(Tabs.medicalHistory)
//                .tabItem {
//                    Label("MOCK_MEDICAL_HISTORY_TITLE", systemImage: "server.rack")
//                        .sheet(isPresented: $presentingAccount) {
//                            AccountSheet()
//                        }
//                }
//            AllergyView()
//                .tag(Tabs.allergyRecords)
//                .tabItem {
//                    Label("MOCK_ALLERGY_RECORDS_TITLE", systemImage: "server.rack")
//                }
//            MedicationView()
//                .tag(Tabs.medications)
//                .tabItem {
//                    Label("MOCK_MEDICATIONS_RECORDS_TITLE", systemImage: "server.rack")
//                }
//            SurgeryView()
//                .tag(Tabs.surgeries)
//                .tabItem {
//                    Label("MOCK_SURGERY_RECORDS_TITLE", systemImage: "server.rack")
//                }
//            LLMInteraction(presentingAccount: $presentingAccount)
//                .tag(Tabs.form)
//                .tabItem {
//                    Label("Create Form", systemImage: "captions.bubble.fill")
//                }
//        }
            
        .sheet(isPresented: $presentingAccount) {
            AccountSheet()
        }
        .accountRequired(Self.accountEnabled) {
            AccountSheet()
        }
        .verifyRequiredAccountDetails(Self.accountEnabled)
        .toolbar {
            settingsToolbarItem
        }
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
