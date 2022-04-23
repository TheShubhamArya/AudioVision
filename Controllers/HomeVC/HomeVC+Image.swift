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
        activityIndicator.startAnimating()
        for (i,image) in images.enumerated() {
            let fixedImage = image.fixOrientation
            visionImages.append(fixedImage)
            print("images ",i)
            DispatchQueue.global(qos: .userInitiated).async {
                print("background thread")
                self.textDetector.recognizeTextFromCamera(with: fixedImage) { text in
                    let correctedtText = self.languageProcessor.getCorrectedText(for: text)
                    self.speechService.speechTexts.append(correctedtText)
                    let emojiStr = self.languageProcessor.getEmojiSentiment(with: text)
                    let emojiImg = emojiStr.toImage() ?? "⚠️".toImage()
                    self.speechService.emojis.append(emojiImg!)

                    
                }

                DispatchQueue.main.async {
                    print("This is run on the main queue, after the previous code in outer block")
                    self.collectionView.reloadData()
                    self.addControlView()
                    self.activityIndicator.stopAnimating()
                }
            }
            
//            recognizeText(with: fixedImage)
        }
//        self.activityIndicator.stopAnimating()
//        DispatchQueue.main.async { [weak self] in
//            self?.collectionView.reloadData()
//            self?.addControlView()
//            self?.activityIndicator.stopAnimating()
//        }
//        activityIndicator.stopAnimating()
    }
    
}
