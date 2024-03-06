// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


import SwiftUI
import PDFKit

struct SimplePDFView: View {
    @State private var pdfData: Data?
    @State private var isSharingPDF = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Hello, PDF!")
                    .font(.title)
                Text("This is a simple PDF rendering example.")
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button(action: {
                pdfData = exportAsPDF()
                isSharingPDF = true
            }) {
                Image(systemName: "square.and.arrow.up")
            })
            .sheet(isPresented: $isSharingPDF) {
                if let pdfData = pdfData {
                    ShareSheet(activityItems: [pdfData])
                }
            }
        }
    }

    @MainActor func exportAsPDF() -> Data? {
        let renderer = ImageRenderer(content: self)
        
        let size = CGSize(width: 8.5 * 72, height: 11 * 72) // Size for standard US Letter
        renderer.proposedSize = ProposedViewSize(size)
        
        let pdfData = NSMutableData()
        renderer.render { _, context in
            var box = CGRect(origin: .zero, size: size)
            guard let consumer = CGDataConsumer(data: pdfData),
                  let pdfContext = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                return
            }
            
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        return pdfData as Data
    }
}

// Wrapper for UIActivityViewController for sharing
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

struct SimplePDFView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePDFView()
    }
}
