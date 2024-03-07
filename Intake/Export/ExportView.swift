// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
//

// swiftlint disable: closure_body_length
import SwiftUI
import UIKit

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func todayDateString() -> String {
    let today = Date()
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter.string(from: today)
}

struct ContentView: View {
    @State private var isSharing = false
    @State private var pdfData: Data?
// swiftlint:disable closure_body_length
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
                    // swiftlint:enable:closure_body_length

                    Spacer()
        }
            // .navigationBarTitle("Share With Doctor", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: shareButtonTapped) {
                Image(systemName: "square.and.arrow.up")
            })
        }
        .sheet(isPresented: $isSharing, onDismiss: {
            self.pdfData = nil
        }) {
            if let pdfData = pdfData {
                ShareSheet(activityItems: [pdfData])
            }
        }
    }

    private func shareButtonTapped() {
        self.pdfData = self.exportToPDF()
        self.isSharing = true
    }

    private func exportToPDF() -> Data {
        let pageSize = CGSize(width: 595, height: 842)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        let data = pdfRenderer.pdfData { ctx in
            ctx.beginPage()

            // Create an instance of ContentView
            let contentView = ContentView()
                .frame(width: pageSize.width, height: pageSize.height)

            // Render the ContentView within a UIHostingController
            let hostingController = UIHostingController(rootView: contentView)

            let view = hostingController.view!
            view.bounds = CGRect(origin: .zero, size: pageSize)
            view.backgroundColor = .clear

            let rendererContext = UIGraphicsGetCurrentContext()!
            view.layer.render(in: rendererContext)
        }
        return data
    }

}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

