// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
//

// swiftlint disable: closure_body_length
import PDFKit
import SpeziFHIR
import SwiftUI
import UIKit

// swiftlint:disable file_types_order
struct ExportView: View {
    @Environment(DataStore.self) var data
    @State private var isSharing = false
    @State private var pdfData: PDFDocument?
    
    // swiftlint:disable closure_body_length
    var body: some View {
        ScrollView {
            self.wrappedBody
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await shareButtonTapped() }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .accessibilityLabel("Share Intake form")
                }
            }
        }
        .sheet(isPresented: $isSharing) {
            if let pdfData = self.pdfData {
                ShareSheet(sharedItem: pdfData)
                    .presentationDetents([.medium])
            } else {
                ProgressView()
                    .padding()
                    .presentationDetents([.medium])
            }
        }
        .onChange(of: pdfData) {
            print("PDF data changed")
        }
    }
    
    // FOR UPDATED SURGERY STRUCT
//    ForEach(data.surgeries, id: \.self) { item in
//        if !item.startDate.isEmpty && !item.endDate.isEmpty && !item.complications.isEmpty{
//            HStack {
//                Text(item.surgeryName)
//                Text(item.startDate)
//                Text(item.endDate)
//                Text(item.complications)
//            }
//        }
//    }
    
//                    ForEach([1,2,3], id: \.self) { item in
//                        Text(String(item))
//                    }
    
    
    private var wrappedBody: some View {
        VStack {
            Text("MEDICAL HISTORY").fontWeight(.bold)
            
            Spacer()
                .frame(height: 20)
            
            VStack(alignment: .leading) {
                Group {
                    HStack {
                        Text("Date:").fontWeight(.bold)
                        Text(todayDateString())
                    }
                    HStack {
                        Text("Name:").fontWeight(.bold)
                        Text("John Doe")
                    }
                    HStack {
                        Text("Date of Birth:").fontWeight(.bold)
                        Text("January 1, 1980")
                    }
                    HStack {
                        Text("Age:").fontWeight(.bold)
                        Text("35")
                    }
                    HStack {
                        Text("Sex:").fontWeight(.bold)
                        Text("Female")
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    
                    VStack(alignment: .leading) {
                        Text("Chief Complaint:").fontWeight(.bold)
                        if data.chiefComplaint.isEmpty {
                            Text("Patient did not enter chief complaint.")
                        } else {
                            Text(data.chiefComplaint)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    
                    VStack(alignment: .leading) {
                        Text("Past Medical History:").fontWeight(.bold)
                        if data.conditionData.isEmpty {
                            Text("No medical conditions")
                        } else {
                            List(data.conditionData, id: \.id) { item in
                                Text(item.condition)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    VStack(alignment: .leading) {
                        Text("Past Surgical History:").fontWeight(.bold)
                        if data.surgeries.isEmpty {
                            Text("No past surgeries")
                        } else {
                            List(data.surgeries, id: \.id) { item in
                                Text(item.surgeryName)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    VStack(alignment: .leading) {
                        Text("Medications:").fontWeight(.bold)
                        if data.medicationData.isEmpty {
                            Text("No medications")
                        } else {
                            List(Array(data.medicationData), id: \.id) { item in
                                HStack {
                                    Text(item.type.localizedDescription)
                                    Text(item.dosage.localizedDescription)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    VStack(alignment: .leading) {
                        Text("Allergies:").fontWeight(.bold)
                        if data.allergyData.isEmpty {
                            Text("No known allergies")
                        } else {
                            List(data.allergyData, id: \.id) { item in
                                HStack {
                                    Text(item.allergy)
                                    List(item.reaction, id: \.id) { reactionItem in
                                        Text(reactionItem.reaction)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    VStack(alignment: .leading) {
                        Text("Review of Systems:").fontWeight(.bold)
                        HStack {
                            Text("Last Menstrural Period")
                            Text("Date")
                        }
                        
                        HStack {
                            Text("Smoking history")
                            Text("0 pack years")
                        }
                    }
                }
            }
            // swiftlint:enable:closure_body_length
            Spacer()
        }
    }
    
    @MainActor
    private func shareButtonTapped() async {
        self.pdfData = await self.exportToPDF()
        self.isSharing = true
    }
    
    
    @MainActor
    func exportToPDF() async -> PDFDocument? {
        let renderer = ImageRenderer(content: self.wrappedBody)
        
        // issue: proposed height is not expanding as necessary. uncomment to attempt to fix this.
        
        // var proposedHeightOptional = renderer.uiImage?.size.height
        
        // guard let proposedHeight = proposedHeightOptional else {
        //    return nil
        // }
        
        // let pageSize = CGSize(width: 612, height: proposedHeight)
        
        let pageSize = CGSize(width: 612, height: 920)
        
        renderer.proposedSize = .init(pageSize)
        
        return await withCheckedContinuation { continuation in
            renderer.render { _, context in
                var box = CGRect(origin: .zero, size: pageSize)
                
                /// Create in-memory `CGContext` that stores the PDF
                guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0),
                      let consumer = CGDataConsumer(data: mutableData),
                      let pdf = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                pdf.beginPDFPage(nil)
                pdf.translateBy(x: 50, y: -50)
                
                context(pdf)
                
                pdf.endPDFPage()
                pdf.closePDF()
                
                continuation.resume(returning: PDFDocument(data: mutableData as Data))
            }
        }
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    let sharedItem: PDFDocument
    
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Note: Need to write down the PDF to storage as in-memory PDFs are not recognized properly
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

func todayDateString() -> String {
    let today = Date()
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter.string(from: today)
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
    }
}