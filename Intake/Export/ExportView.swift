//
//  ExportView.swift
//  Intake
//
//  Created by Zoya Garg on 3/4/24.
//

import Foundation
import UIKit
import PDFKit
import SwiftUI


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

