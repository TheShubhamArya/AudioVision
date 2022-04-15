//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/6/22.
//

import UIKit

extension HomeVC {
    
    @objc func playButtonTapped() {
        let row = currentReadingCell
        controlView.pageLabel.text = "\(row+1) off \(speechService.speechTexts.count)"
        if let cell = collectionView.cellForItem(at: IndexPath(item: row, section: 0)) as? PageCell {
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.systemYellow.cgColor
            frontView = cell.frontView
        }
        
        speechService.synthesizer.delegate = self
        speechService.isSpeaking[row] = !speechService.isSpeaking[row]
        
        if speechService.isSpeaking[row] {
            if speechService.startSpeakingCounter[row] == 0 {
                speechService.startSpeaking(for: row)
            } else {
                speechService.continueSpeaking()
            }
        } else {
            speechService.pauseSpeaking()
        }
        speechService.startSpeakingCounter[row] += 1
        controlView.changedButtonImage(speechService.isSpeaking[row])
    }
    
    @objc func forwardButtonTapped()  {
        let row = currentReadingCell
        if let cell = collectionView.cellForItem(at: IndexPath(item: row, section: 0)) as? PageCell {
            cell.layer.borderColor = UIColor.quaternaryLabel.cgColor
            cell.frontView.textView.text = speechService.speechTexts[row]
        }
        
        speechService.startSpeakingCounter = [Int](repeating: 0, count: speechService.speechTexts.count)
        speechService.stopSpeaking()
        speechService.isSpeaking[row] = false
        currentReadingCell += 1
        currentReadingCell %= speechService.speechTexts.count
        playButtonTapped()
    }
    
    @objc func backButtonTapped() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: currentReadingCell, section: 0)) as? PageCell {
            cell.layer.borderColor = UIColor.quaternaryLabel.cgColor
            cell.frontView.textView.text = speechService.speechTexts[currentReadingCell]
        }
        speechService.startSpeakingCounter = [Int](repeating: 0, count: speechService.speechTexts.count)
        speechService.stopSpeaking()
        speechService.isSpeaking[currentReadingCell] = false
        currentReadingCell -=  1
        if currentReadingCell < 0 {
            currentReadingCell = speechService.speechTexts.count - 1
        }
        playButtonTapped()
    }
    
    func addControlView() {
        view.addSubview(controlView)
        controlView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 20),
            controlView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -20),
            controlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            controlView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        controlView.playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        controlView.forwardButton.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        controlView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
}
