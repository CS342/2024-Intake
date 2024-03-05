//
//  ExportView.swift
//  Intake
//
//  Created by Zoya Garg on 3/4/24.
//

import Foundation
import UIKit
import PDFKit

func generatePDF() -> Data {
    let pdfData = NSMutableData()
    UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: 612, height: 792), nil)
    
    guard let pdfContext = UIGraphicsGetCurrentContext() else { return Data() }
    
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
    
    UIGraphicsEndPDFContext()
    
    return pdfData as Data
}

func displayPDF() {
    let pdfData = generatePDF()
    let pdfView = PDFView(frame: self.view.bounds)
    pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.view.addSubview(pdfView)
    
    if let document = PDFDocument(data: pdfData) {
        pdfView.document = document
    }
}
