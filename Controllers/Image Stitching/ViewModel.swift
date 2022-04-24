//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/22/22.
//

import SwiftUI
import AVKit
import AVFoundation

class ViewModel: NSObject, ObservableObject {
    private let speechSynthesizer = SpeechSynthesizer()
    private let speechRecognizer = SpeechRecognizer()
    
    var didStartSpeaking = false
    var isSpeaking = false
    var text = ""
    
    override init() {
        super.init()
        speechRecognizer.speechRecognizerDelegate = self
        speechRecognizer.recognizeSpeech()
        speechSynthesizer.synthesizer.delegate = self
    }
    
    func startSpeaking(with text: String) {
        isSpeaking = !isSpeaking
        if !didStartSpeaking {
            didStartSpeaking = true
            if isSpeaking {
                speechSynthesizer.startSpeaking(with: text)
            } else {
                speechSynthesizer.pauseSpeaking()
            }
            
        } else {
            if isSpeaking {
                speechSynthesizer.continueSpeaking()
            } else {
                speechSynthesizer.pauseSpeaking()
            }
        }
    }
    
    func dismissAction() {
        DispatchQueue.main.async {
            UIApplication.kTopViewController()?.dismiss(animated: true)
        }
        
    }
}

extension ViewModel : AVSpeechSynthesizerDelegate  {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("khatam ho gaya bro")
        speechSynthesizer.stopSpeaking()
        didStartSpeaking = false
    }
    
}

extension ViewModel : SpeechRecognizerDelegate {
    func didSayCorrectKeyword(for keyword: KeyWords) {
        speechRecognizer.stopRecognizingSpeech()
        if keyword == .readToMe {
            didStartSpeaking = false
            isSpeaking = false
            startSpeaking(with: text)
        } else if keyword == .done {
            dismissAction()
        }
        speechRecognizer.recognizeSpeech()
    }
}
