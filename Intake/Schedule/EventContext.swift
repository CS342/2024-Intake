//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziScheduler

struct EventContext: Comparable, Identifiable {
    let event: Event
    let task: Task<IntakeTaskContext>

    var id: Event.ID {
        event.id
    }

    static func < (lhs: EventContext, rhs: EventContext) -> Bool {
        lhs.event.scheduledAt < rhs.event.scheduledAt
    }
}
