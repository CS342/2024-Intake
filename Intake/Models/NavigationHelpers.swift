//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


@Observable
class NavigationPathWrapper {
    var path = NavigationPath()
}

@Observable
class ReachedEndWrapper {
    var reachedEnd = false
    var surgeriesLoaded = false
}

@Observable
class LoadedWrapper {
    var conditionData = false
    var allergyData = false
}


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
