//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/6/22.
//

import UIKit

//MARK: - Custom Image Picker delegate
extension HomeVC : CapturedImageProtocol {
    
    func openCamera() {
        if didOpenCamera {
            didOpenCamera = false
            speechService.stopSpeaking()
            let captureImageVC = CaptureImageVC()
            captureImageVC.captureImageDelegate = self
            navigationController?.pushViewController(captureImageVC, animated: true)
        }
    }
    
    func didReturnCapturedImages(with images: [UIImage]) {
        if !images.isEmpty {
            collectionView.restore()
        }
        for image in images {
            let fixedImage = image.fixOrientation
            visionImages.append(fixedImage)
            recognizeText(with: fixedImage)
        }
    }
    
}
