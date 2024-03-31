//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import SwiftUI


extension ExportView {
    struct ShareSheet: UIViewControllerRepresentable {
        let sharedItem: PDFDocument
        
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let temporaryPath = FileManager.default.temporaryDirectory.appendingPathComponent(
                LocalizedStringResource("Intake Form").localizedString() + ".pdf"
            )
            try? sharedItem.dataRepresentation()?.write(to: temporaryPath)
            
            let controller = UIActivityViewController(
                activityItems: [temporaryPath],
                applicationActivities: nil
            )
            controller.completionWithItemsHandler = { _, _, _, _ in
                try? FileManager.default.removeItem(at: temporaryPath)
            }
            
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
}
