//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/6/22.
//

import UIKit
import AVFoundation

extension HomeVC : AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttributes([.backgroundColor: UIColor.systemYellow, .font: UIFont.systemFont(ofSize: 17, weight: .regular)], range: characterRange)
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentReadingCell, section: 0)) as? PageCell else {return}
        cell.frontView.textView.attributedText = mutableAttributedString
        cell.frontView.textView.textColor = .label
        cell.frontView.textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentReadingCell, section: 0)) as? PageCell else {return}
        cell.frontView.textView.attributedText = NSAttributedString(string: utterance.speechString)
        cell.layer.borderColor = UIColor.quaternaryLabel.cgColor
        cell.frontView.textView.textColor = .label
        cell.frontView.textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        speechService.isSpeaking[currentReadingCell] = false
        controlView.changedButtonImage(speechService.isSpeaking[currentReadingCell])
    }
}
