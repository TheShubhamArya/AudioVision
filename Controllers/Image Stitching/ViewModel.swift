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
            UIApplication.topViewController()?.dismiss(animated: true)
        }
        
    }
}

extension ViewModel : SpeechRecognizerDelegate {
    func didSayCorrectKeyword(for keyword: KeyWords) {
        speechRecognizer.stopRecognizingSpeech()
        if keyword == .read {
            didStartSpeaking = false
            isSpeaking = false
            startSpeaking(with: text)
        } else if keyword == .pause {
            isSpeaking  = true
            startSpeaking(with: text)
        } else if keyword == .continu {
            isSpeaking = false
            startSpeaking(with: text)
        } else if keyword == .dismiss {
            dismissAction()
        }
        speechRecognizer.recognizeSpeech()
    }
}
