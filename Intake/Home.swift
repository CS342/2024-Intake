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
    
//    @State var navigationPath = NavigationPath()
    
    var body: some View {
//        NavigationStack(path: $navigationPath) {   // swiftlint:disable:this closure_body_length
//            LLMInteraction(presentingAccount: $presentingAccount)
//                .navigationDestination(for: NavigationViews.self) { view in
//                switch view {
//                case .allergies: AllergyViewTest()
//                default: SummaryView(chiefComplaint: "blah blah blah")
//                    // Fill in rest from NavigationView
//                }
//            }
//        }
//        .environmentObject(navigationPath)
        
        
        TabView(selection: $selectedTab) { // swiftlint:disable:this closure_body_length
            ScheduleView(presentingAccount: $presentingAccount)
                .tag(Tabs.schedule)
                .tabItem {
                    Label("SCHEDULE_TAB_TITLE", systemImage: "list.clipboard")
                }
            Contacts(presentingAccount: $presentingAccount)
                .tag(Tabs.contact)
                .tabItem {
                    Label("CONTACTS_TAB_TITLE", systemImage: "person.fill")
                }
            if FeatureFlags.disableFirebase {
                MockUpload(presentingAccount: $presentingAccount)
                    .tag(Tabs.mockUpload)
                    .tabItem {
                        Label("MOCK_WEB_SERVICE_TAB_TITLE", systemImage: "server.rack")
                    }
            }
            SocialHistoryQuestionView()
                .tag(Tabs.socialHistory)
                .tabItem {
                    Label("Social History", systemImage: "person.line.dotted.person")
                }
            MedicalHistoryView()
                .tag(Tabs.medicalHistory)
                .tabItem {
                    Label("MOCK_MEDICAL_HISTORY_TITLE", systemImage: "server.rack")
                        .sheet(isPresented: $presentingAccount) {
                            AccountSheet()
                        }
                }
            AllergyView()
                .tag(Tabs.allergyRecords)
                .tabItem {
                    Label("MOCK_ALLERGY_RECORDS_TITLE", systemImage: "server.rack")
                }
            MedicationView()
                .tag(Tabs.medications)
                .tabItem {
                    Label("MOCK_MEDICATIONS_RECORDS_TITLE", systemImage: "server.rack")
                }
            SurgeryView()
                .tag(Tabs.surgeries)
                .tabItem {
                    Label("MOCK_SURGERY_RECORDS_TITLE", systemImage: "server.rack")
                }
            LLMInteraction(presentingAccount: $presentingAccount)
                .tag(Tabs.form)
                .tabItem {
                    Label("Create Form", systemImage: "captions.bubble.fill")
                }
        }
            
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
