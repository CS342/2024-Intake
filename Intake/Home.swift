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
}

struct StartButton: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Button(action: {
            navigationPath.append(NavigationViews.general)
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
        
        NavigationStack(path: $navigationPath.path) { // swiftlint:disable:this closure_body_length
            VStack { // swiftlint:disable:this closure_body_length
                HStack {
                    Spacer()
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
                    .padding()
                }

        NavigationStack(path: $navigationPath.path) {
            VStack {
                Spacer()
                homeLogo
                homeTitle
                Spacer()
                StartButton(navigationPath: $navigationPath.path)
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
