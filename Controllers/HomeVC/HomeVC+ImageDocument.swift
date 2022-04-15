//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/6/22.
//

import UIKit
import PhotosUI
import PDFKit

//MARK: - Custom Image Picker delegate
extension HomeVC : CapturedImageProtocol {
    
    func openCamera() {
        let captureImageVC = CaptureImageVC()
        captureImageVC.captureImageDelegate = self
        navigationController?.pushViewController(captureImageVC, animated: true)
    }
    
    func didReturnCapturedImages(with images: [UIImage]) {
        collectionView.restore()
        for image in images {
            let fixedImage = image.fixOrientation
            visionImages.append(fixedImage)
            recognizeText(with: fixedImage)
        }
    }
    
}

//MARK: - Delegate for PHPicker to select multiple images
extension HomeVC : PHPickerViewControllerDelegate {
    
    @objc func pickPhotos(){
        var config = PHPickerConfiguration()
        config.selectionLimit = 10
        config.filter = PHPickerFilter.images
        config.selection = .ordered
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        visionImages = []
        if !results.isEmpty {
            collectionView.restore()
            activityIndicator.startAnimating()
        }
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    
                    self.visionImages.append(image)
                    DispatchQueue.main.async {
                        self.recognizeText(with: image,1)
                    }
                }
            })
        }
        
    }
}

//MARK: - Document picker delegate
extension HomeVC: UIDocumentPickerDelegate {
    
    func openFilesApp() {
        let docPicker = UIDocumentPickerViewController(forOpeningContentTypes: K.docsTypes, asCopy: true)
        docPicker.delegate = self
        docPicker.shouldShowFileExtensions = true
        docPicker.allowsMultipleSelection = true
        self.present(docPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            activityIndicator.startAnimating()
            if let pdf = PDFDocument(url: url) {
                let pageCount = pdf.pageCount
                for i in 0 ..< pageCount {
                    guard let page = pdf.page(at: i) else { continue }
                    guard let pageContent = page.string else {continue}
                    let screenSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)

                    let image = page.thumbnail(of: screenSize, for: .mediaBox)
                    visionImages.append(image)
                    speechService.speechTexts.append(pageContent)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
