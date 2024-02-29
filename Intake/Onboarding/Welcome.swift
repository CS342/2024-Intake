//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI

struct Welcome: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        OnboardingView(
            title: "Welcome to ReForm",
            subtitle: "This application will help autocomplete your medical intake form.",
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "folder.fill.badge.plus")
                            .accessibilityHidden(true)
                    },
                    title: "Integrate your Records",
                    description: "Download your medical records from your health system."
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Auto-fill Intake Form",
                    description: "Review summary of your medical history."
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "square.and.arrow.up.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Submit your Form",
                    description: "Share with provider of your choice."
                )
            ],
            actionText: "Get Started",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
            .padding(.top, 24)
    }
}

#if DEBUG
#Preview {
    OnboardingStack {
        Welcome()
    }
}
#endif
