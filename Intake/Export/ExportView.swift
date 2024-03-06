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
        
        struct PDFViewer: UIViewRepresentable {
            var data: Data
            
            func makeUIView(context: Context) -> PDFView {
                let pdfView = PDFView()
                pdfView.autoScales = true
                return pdfView
            }
            
            func updateUIView(_ uiView: PDFView, context: Context) {
                uiView.document = PDFDocument(data: data)
            }
        }
        
        
        struct ExportView: View {
            var body: some View {
                PDFViewer(data: generatePDF())
                    .edgesIgnoringSafeArea(.all) // Use the entire screen
                Text("PDF Export Placeholder")
                // You can replace this Text view with your actual view content
                // For displaying a PDF, you would use a UIViewRepresentable wrapper around PDFKit's PDFView
            }
            
            
            func generatePDF() -> Data {
                let pdfData = NSMutableData()
                UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: 612, height: 792), nil)
                
                guard let pdfContext = UIGraphicsGetCurrentContext() else { return Data() }
                pdfContext.saveGState()
                
                UIGraphicsBeginPDFPage()
                
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.black
                ]
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]
                
                let title = "Sample Title"
                title.draw(at: CGPoint(x: 20, y: 20), withAttributes: titleAttributes)
                
                let text = "This is some sample content for the PDF."
                text.draw(at: CGPoint(x: 20, y: 50), withAttributes: textAttributes)
                
                pdfContext.restoreGState()
                UIGraphicsEndPDFContext()
                
                return pdfData as Data
            }
            
            struct ExportView_Previews: PreviewProvider {
                static var previews: some View {
                    ExportView()
                        .previewDevice("iPhone 12") // Specify the device you want to preview on
                }
            }
        }
        
    }
