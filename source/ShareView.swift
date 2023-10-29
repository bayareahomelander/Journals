//
//  ShareView.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-04.
//

import Foundation
import SwiftUI
import Photos
import UIKit

struct ShareView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var eventName: String = ""
    @State private var eventDate: String = ""
    @State private var daysLeftOrPassed: String = ""
    @State private var capturedImage: UIImage?
    @State private var showSaveAlert = false
    @State private var photoSaver: PhotoSaver? = nil
    
    init(eventName: String, eventDate: String, daysLeftOrPassed: String) {
        self._eventName = State(initialValue: eventName)
        self._eventDate = State(initialValue: eventDate)
        self._daysLeftOrPassed = State(initialValue: daysLeftOrPassed)
    }
    
    var body: some View {
        NavigationView {
            ImageTemplateView(
                title: eventName,
                days: daysLeftOrPassed,
                date: eventDate
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundStyle(Color.dynamicText)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { // Capture UI view as an image and save to photo album
                        let hostingController = UIHostingController(rootView: ImageTemplateView(title: eventName, days: daysLeftOrPassed, date: eventDate))
                        let customSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        hostingController.view.frame = CGRect(origin: .zero, size: customSize)
                        hostingController.view.backgroundColor = .clear
                        
                        let image = renderUIViewToImage(view: hostingController.view, size: customSize)
                        
                        self.photoSaver = PhotoSaver(showSaveAlert: $showSaveAlert)
                        UIImageWriteToSavedPhotosAlbum(image, photoSaver, #selector(photoSaver?.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }) {
                        Text("Save")
                            .foregroundStyle(Color.dynamicText)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showSaveAlert) {
            Alert(
                title: Text(photoSaver?.alertTitle ?? ""),
                message: Text(photoSaver?.alertMessage ?? ""),
                dismissButton: .default(Text("OK"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            )
        }
    }
}

class PhotoSaver: NSObject {
    var alertMessage: String = ""
    var alertTitle: String = ""
    var showSaveAlert: Binding<Bool>
    
    init(showSaveAlert: Binding<Bool>) {
        self.showSaveAlert = showSaveAlert
    }

    // Handle completion, conditionally display message
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            alertTitle = "Error"
            alertMessage = "Save error: \(error.localizedDescription)"
        } else {
            alertTitle = "Success"
            alertMessage = "Picture saved to album."
        }
        showSaveAlert.wrappedValue = true
    }
}
