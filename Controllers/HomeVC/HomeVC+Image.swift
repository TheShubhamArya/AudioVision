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
            activityIndicator.startAnimating()
        }
        for image in images {
            let fixedImage = image.fixOrientation
            visionImages.append(fixedImage)
            DispatchQueue.global(qos: .userInitiated).async {
                self.textDetector.recognizeTextFromCamera(with: fixedImage) { text in
                    let correctedtText = self.languageProcessor.getCorrectedText(for: text)
                    self.speechService.speechTexts.append(correctedtText)
                    let emojiStr = self.languageProcessor.getEmojiSentiment(with: text)
                    let emojiImg = emojiStr.toImage() ?? "⚠️".toImage()
                    self.speechService.emojis.append(emojiImg!)

                    
                }

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.addControlView()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
}
