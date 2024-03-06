// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


import PDFKit
import SwiftUI

func todayDateString() -> String {
    let today = Date()
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter.string(from: today)
}

struct SimplePDFView: View {
    @State private var pdfData: Data?
    @State private var isSharingPDF = false

// swiftlint:disable closure_body_length
    var body: some View {
        
        NavigationView {
            VStack {
                Text("MEDICAL HISTORY").fontWeight(.bold)
                
                HStack {
                    Text(" ")
                }
                
                
                VStack(alignment: .leading){
                    
                    
                    Group {
                        HStack {
                            Text("Date:").fontWeight(.bold)
                            Text(todayDateString())
                        }.padding(.leading, -50)
                        HStack {
                            Text("Name:").fontWeight(.bold)
                            Text("John Doe")
                        }.padding(.leading, -50)
                        HStack {
                            Text("Date of Birth:").fontWeight(.bold)
                            // Replace with dynamic date of birth
                            Text("January 1, 1980")
                        }.padding(.leading, -50)
                        HStack {
                            Text("Age:").fontWeight(.bold)
                            // Replace with dynamic date of birth
                            Text("35")
                        }.padding(.leading, -50)
                        HStack {
                            Text("Sex:").fontWeight(.bold)
                            // Replace with dynamic date of birth
                            Text("Female")
                        }.padding(.leading, -50)
                        HStack {
                            Text(" ")
                        }
                        
                        
                        
                        VStack(alignment: .leading) {
                            Text("Chief Complaint:").fontWeight(.bold)
                            // Replace with dynamic date of birth
                            Text("Chief Complaint here")
                        }.padding(.leading, -50)
                        
                        HStack {
                            Text(" ")
                        }
                        
                        
                        
                        VStack(alignment: .leading) {
                            Text("Past Medical History:").fontWeight(.bold)
                            // Replace with dynamic date of birth
                            Text("Medical History Here")
                        }.padding(.leading, -50)
                        
                        HStack {
                            Text(" ")
                        }
                        
                        
                        VStack(alignment: .leading) {
                            Text("Past Surgical History:").fontWeight(.bold)
                            // Replace with dynamic date of birth
                            Text("Medical History Here")
                        }.padding(.leading, -50)
                        
                        
                        HStack {
                            Text(" ")
                        }
                        
                        
                        VStack(alignment: .leading) {
                            Text("Medications:").fontWeight(.bold)
                            // Replace with dynamic date of birth
//                            
                            HStack{
                                Text("Medication")
                                Text("Dosage")
                                Text("by mouth")
                                Text("once a day")
                                
                            }
                            
                            
                        }.padding(.leading, -50)
                        
                        
                        HStack {
                            Text(" ")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Allergies:").fontWeight(.bold)
                            // Replace with dynamic date of birth
//
                            HStack{
                                Text("Allergy")
                                Text("Reaction")
                                
                            }
                            
                            
                        }.padding(.leading, -50)
                        
                        HStack {
                            Text(" ")
                        }
                        
                        
                        VStack(alignment: .leading) {
                            Text("Review of Systems:").fontWeight(.bold)
                            // Replace with dynamic date of birth
//
                            HStack{
                                Text("Last Menstrural Period")
                                Text("Date")
                                
                            }
                            
                            HStack{
                                Text("Smoking history")
                                Text("20 pack years")
                                
                            }
                            
                            
                            
                        }.padding(.leading, -50)
                        
                        
                        
                        
                    }
                    
                    
                }


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
        
// PDFViewer to display a PDF
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

// Separate Preview Provider for PDFViewer
struct PDFViewer_Previews: PreviewProvider {
    static var previews: some View {
        PDFViewer(data: Data()) // Provide some sample data for the preview
    }
}
        
struct ExportView: View {
    var body: some View {
        VStack {
            PDFViewer(data: generatePDF())
                .edgesIgnoringSafeArea(.all)
            Text("PDF Export Placeholder")
        }
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
    
    // Separate Preview Provider for ExportView
    struct ExportView_Previews: PreviewProvider {
        static var previews: some View {
            ExportView()
                .previewDevice("iPhone 12")
        }
    }
}
