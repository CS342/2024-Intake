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

// Again, I had to disable this error as it was causing issues and could not be resolved.
// swiftlint:disable file_types_order
struct ExportView: View {
    @Environment(DataStore.self) var data
    @State private var isSharing = false
    @State private var pdfData: PDFDocument?
    
    // A long closure body length here is imperative for this view to be formatted correctly. Thus, I had to disable this warning.
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
                        Text(data.generalData.name)
                    }
                    HStack {
                        Text("Date of Birth:").fontWeight(.bold)
                        Text(data.generalData.birthdate)
                    }
                    HStack {
                        Text("Age:").fontWeight(.bold)
                        Text(data.generalData.age)
                    }
                    HStack {
                        Text("Sex:").fontWeight(.bold)
                        Text(data.generalData.name)
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
                            ForEach(data.conditionData, id: \.id) { item in
                                HStack {
                                    Text(item.condition)
                                    Spacer()
                                    Text(item.active ? "Active" : "Inactive")
                                        .foregroundColor(.secondary)
                                }
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
                            ForEach(data.surgeries, id: \.id) { item in
                                HStack {
                                    Text(item.surgeryName)
                                    Text(item.date).foregroundColor(.secondary)
                                }
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
                            ForEach(Array(data.medicationData), id: \.id) { item in
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
                            ForEach(data.allergyData, id: \.id) { item in
                                VStack(alignment: .leading) {
                                    Text(item.allergy).fontWeight(.bold)
                                    ForEach(item.reaction, id: \.id) { reactionItem in
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
        
        let proposedHeightOptional = renderer.uiImage?.size.height
        
        guard let proposedHeight = proposedHeightOptional else {
            return nil
        }
        
        let pageSize = CGSize(width: 612, height: proposedHeight)
        
        renderer.proposedSize = .init(pageSize)
        
        return await withCheckedContinuation { continuation in
            renderer.render { _, context in
                var box = CGRect(origin: .zero, size: pageSize)
                
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
