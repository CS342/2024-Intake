//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziContact
import SwiftUI


/// Displays the contacts for the Intake.
struct Contacts: View {
    let contacts = [
        Contact(
            name: PersonNameComponents(
                givenName: "Oliver O.",
                familyName: "Aalami"
            ),
            image: Image("ProfilePicture"), // swiftlint:disable:this accessibility_label_for_image
            title: "CLINICAL PROFESSOR, SURGERY - VASCULAR SURGERY",
            description: String(localized: "OLIVER_AALAMI_BIO"),
            organization: "Stanford University",
            address: {
                let address = CNMutablePostalAddress()
                address.country = "USA"
                address.state = "CA"
                address.postalCode = "94305"
                address.city = "Stanford"
                address.street = "300 Pasteur Dr"
                address.subAdministrativeArea = "Rm H3640 MC 5308"
                return address
            }(),
            contactOptions: [
                .call("+1 (650) 725-5227"),
                .text("+1 (650) 725-5227"),
                .email(addresses: ["aalami@stanford.edu"]),
                ContactOption(
                    image: Image(systemName: "safari.fill"), // swiftlint:disable:this accessibility_label_for_image
                    title: "Website",
                    action: {
                        if let url = URL(string: "https://profiles.stanford.edu/oliver-aalami") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            ]
        )
    ]
    
    @Binding var presentingAccount: Bool
    
    
    var body: some View {
        NavigationStack {
            ContactsList(contacts: contacts)
                .navigationTitle(String(localized: "CONTACTS_NAVIGATION_TITLE"))
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
        }
    }
    
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}


#if DEBUG
#Preview {
    Contacts(presentingAccount: .constant(false))
}
#endif
