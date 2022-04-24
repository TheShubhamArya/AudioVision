//
//  File.swift
//  AudioVision
//
//  Created by Shubham Arya on 4/6/22.
//

import Speech

protocol SpeechRecognizerDelegate : AnyObject {
    func didSayCorrectKeyword(for keyword: KeyWords)
}

class SpeechRecognizer {
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask : SFSpeechRecognitionTask?
    weak var speechRecognizerDelegate : SpeechRecognizerDelegate!
    var node : AVAudioInputNode?

    func recognizeSpeech() {
        request = SFSpeechAudioBufferRecognitionRequest()
        node = audioEngine.inputNode
        let recordingFormat = node?.outputFormat(forBus: 0)
        node?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine")
        }
        guard let speechRecognizer = SFSpeechRecognizer() else {
            print("Error initializing speech recognizer")
            return
        }
        if !speechRecognizer.isAvailable {
            print("Speech recognizer is not available")
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { result, error in
            if let err = error {
                print("Error found in recognition task. ",err)
            } else {
                if let result = result {
                    let recognizedSpeech = result.bestTranscription.formattedString.lowercased()
                    print(recognizedSpeech)
                    let (performAction, keyword) = self.shouldPerformAction(with: recognizedSpeech)
                    if performAction {
                        self.stopRecognizingSpeech()
                        self.speechRecognizerDelegate.didSayCorrectKeyword(for: keyword)
                        return
                    }
                }
            }
        })
        if recognitionTask?.error != nil {
            DispatchQueue.main.async { [unowned self] in
                guard let task = self.recognitionTask else {
                    print("error")
                    return
                }
                print("cancel and finish task")
                task.cancel()
                task.finish()
            }
        }
    }
    
    func shouldPerformAction(with speech: String) -> (Bool, KeyWords){
        let openCamera = speech.contains(KeyWords.openCamera.rawValue)
        let takePicture = speech.contains(KeyWords.takePicture.rawValue)
        let readToMe = speech.contains(KeyWords.readToMe.rawValue)
        let done = speech.contains(KeyWords.done.rawValue)
        let openLiveDetection = speech.contains(KeyWords.openLiveDetection.rawValue)
        let start = speech.contains(KeyWords.start.rawValue)
        let stop =  speech.contains(KeyWords.stop.rawValue)
        let quitLiveDetection = speech.contains(KeyWords.quitLiveDetection.rawValue)
        let openImageStitching = speech.contains(KeyWords.openImageStitching.rawValue)
        let quitImageStitching = speech.contains(KeyWords.quitImageStitching.rawValue)
        if openCamera {
            return (true, .openCamera)
        } else if takePicture {
            return (true, .takePicture)
        } else if readToMe {
            return (true, .readToMe)
        } else if done {
            return (true, .done)
        } else if openLiveDetection {
            return (true, .openLiveDetection)
        } else if start {
            return (true, .start)
        } else if stop {
            return (true, .stop)
        } else if quitLiveDetection {
            return (true, .quitLiveDetection)
        } else if openImageStitching {
            return (true, .openImageStitching)
        } else  if  quitImageStitching {
            return (true, .quitImageStitching)
        }
        return (false, .none)
    }
    
    func stopRecognizingSpeech() {
        print("stop  recognizing speech function")
        node?.removeTap(onBus: 0)
        audioEngine.stop()
        self.recognitionTask = nil
    }
    
    func speechRecognitionAuthorization() {
        SFSpeechRecognizer.requestAuthorization {
            [unowned self] (authStatus) in
            print("Speech recognition authorization")
            switch authStatus {
            case .authorized:
                recognizeSpeech()
            case .denied:
                print("Speech recognition authorization denied")
            case .restricted:
                print("Not available on this device")
            case .notDetermined:
                print("Not determined")
            default:
                print("There seems to be some problem.")
            }
        }
    }
}
