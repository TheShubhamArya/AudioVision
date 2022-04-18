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
    
//    let keyWordDict : [String:KeyWords] = ["open camera":.openCamera, "open the camera":.openCamera, "open a camera":.openCamera, "open photos": .openPhotoLibrary, "open photo library": .openPhotoLibrary, "open the photos": .openPhotoLibrary, "select photos": .openPhotoLibrary, "select from photos": .openPhotoLibrary, "select from photo library": .openPhotoLibrary,
//                                           "": .readFromFiles,"": .takePicture, "": .done, "": .readToMe, "": .readPrevious, "": .readNext]

    func recognizeSpeech() {
        print("recognize speech function")
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
        let play = speech.contains(KeyWords.play.rawValue)
        let pause = speech.contains(KeyWords.pause.rawValue)
        let openPhotoLibrary = speech.contains(KeyWords.openPhotoLibrary.rawValue)
        let readFromFiles = speech.contains(KeyWords.readFromFiles.rawValue)
        let readNext = speech.contains(KeyWords.readNext.rawValue)
        let readPrevious = speech.contains(KeyWords.readPrevious.rawValue)
        let done = speech.contains(KeyWords.done.rawValue)
        if openCamera {
            return (true, .openCamera)
        } else if takePicture {
            return (true, .takePicture)
        } else if readToMe {
            return (true, .readToMe)
        } else if play {
            return (true, .play)
        } else if pause {
            return (true, .pause)
        } else if openPhotoLibrary {
            return (true, .openPhotoLibrary)
        } else if readFromFiles {
            return (true, .readFromFiles)
        } else if readNext {
            return (true, .readNext)
        } else if readPrevious {
            return (true, .readPrevious)
        } else if done {
            return (true, .done)
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
