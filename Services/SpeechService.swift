//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import AVFoundation
import UIKit

class SpeechService {
    
    let synthesizer = AVSpeechSynthesizer()
    var speechTexts = [String]()
    var startSpeakingCounter = [Int]()
    var isSpeaking = [Bool]()
    var emojis = [UIImage]()
    
    func startSpeaking(for row: Int){
        let utterance = AVSpeechUtterance(string: speechTexts[row])
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 1.0
//        utterance.rate  =  0.1
//        utterance.pitchMultiplier = 0.5
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .immediate)
    }
    
    func continueSpeaking() {
        synthesizer.continueSpeaking()
    }
}
