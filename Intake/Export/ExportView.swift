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

func exportAsPDF(from view: UIView) -> Data {
    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: view.bounds.origin, size: view.bounds.size))

    let pdfData = pdfRenderer.pdfData { context in
        context.beginPage()
        view.layer.render(in: context.cgContext)
    }

    return pdfData
}

struct SimplePDFView: View {
    @State private var pdfData: Data?
    @State private var isSharingPDF = false
    // swiftlint disable: closure_body_length
    var body: some View {
        NavigationView {
                    VStack {
                        Text("MEDICAL HISTORY").fontWeight(.bold)
                        HStack {
                            Text(" ")
                        }
                        VStack(alignment: .leading) {
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
                                    HStack {
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
                                    HStack {
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
                                    HStack {
                                        Text("Last Menstrural Period")
                                        Text("Date")
                                    }
        
                                    HStack {
                                        Text("Smoking history")
                                        Text("20 pack years")
                                    }
                                }.padding(.leading, -50)
                            }
                        }
                                Spacer()
                    }
        //            .padding()
            .navigationBarItems(trailing: Button(action: {
                let pdfView = UIHostingController(rootView: self).view
                pdfView?.frame = CGRect(origin: .zero, size: CGSize(width: 595, height: 842)) // A4 size
                pdfData = exportAsPDF(from: pdfView!)
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
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SimplePDFView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePDFView()
    }
}
