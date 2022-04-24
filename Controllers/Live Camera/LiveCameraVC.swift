//
//  LiveCameraVC.swift
//  
//
//  Created by Shubham Arya on 4/11/22.
//

import UIKit
import AVKit
import AVFoundation
import SwiftUI

class LiveCameraVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession : AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .iFrame960x540
        return captureSession
    }()

    var captureFrame = true
    var isSpeaking = false
    var didStartSpeaking = false
    var pauseButtonState = true
    var cyclesWithoutTextDetection = 0
    
    private let textView : UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let tintView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.25
        return view
    }()
    
    private let liveButton : UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .semibold, scale: .medium)
        let largeBoldDoc = UIImage(systemName: "pause", withConfiguration: largeConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let speechButton : UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .semibold, scale: .medium)
        let largeBoldDoc = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: largeConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emojiImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var circularProgressAnimation : CABasicAnimation!
    var circularProgressBarView: CircularProgressBarView!
    var circularViewDuration: TimeInterval = 4
    
    let speechService = SpeechSynthesizer()
    let languageProcessor = LanguageProcessor()
    let speechRecognizer = SpeechRecognizer()
    let textDetection = TextDetector()
    
    let instructionView = InstructionView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle"), style: .plain, target: self, action: #selector(helpButtonTapped))
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        layoutElements()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        speechRecognizer.speechRecognizerDelegate = self
        speechRecognizer.speechRecognitionAuthorization()
        let _ = Timer.scheduledTimer(timeInterval: 59, target: self, selector: #selector(restartSpeechRecognition), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        stop()
        speechRecognizer.stopRecognizingSpeech()
    }
    
    @objc func restartSpeechRecognition() {
        speechRecognizer.stopRecognizingSpeech()
        speechRecognizer.recognizeSpeech()
    }
    
    func setupSpeechButton() {
        view.addSubview(speechButton)
        view.addSubview(emojiImageView)
        NSLayoutConstraint.activate([
            emojiImageView.trailingAnchor.constraint(equalTo: liveButton.leadingAnchor, constant: -20),
            emojiImageView.centerYAnchor.constraint(equalTo: liveButton.centerYAnchor),
            emojiImageView.heightAnchor.constraint(equalToConstant: 60),
            emojiImageView.widthAnchor.constraint(equalToConstant: 60),
            
            speechButton.leadingAnchor.constraint(equalTo: liveButton.trailingAnchor, constant: 20),
            speechButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            speechButton.heightAnchor.constraint(equalToConstant: 80),
            speechButton.widthAnchor.constraint(equalToConstant: 80),
        ])
        speechButton.addTarget(self, action: #selector(speechButtonTapped), for: .touchUpInside)
    }
    
    @objc func speechButtonTapped()  {
        isSpeaking = !isSpeaking
        speechActions()
    }
    
    @objc func helpButtonTapped() {
        let vc = LiveCameraHelpView()
        let host = UIHostingController(rootView: vc)
        present(host, animated: true, completion: nil)
    }
    
    @objc func liveButtonTapped() {
        pauseButtonState = !pauseButtonState
        liveButtonAction()
    }
    
    func speechActions() {
        let medConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .semibold, scale: .medium)
        let speakerSlash = UIImage(systemName: isSpeaking ? "speaker.slash.fill" : "speaker.wave.2.fill", withConfiguration: medConfig)
        speechButton.setImage(speakerSlash, for: .normal)
        if isSpeaking {
            didStartSpeaking ? speechService.continueSpeaking() : speechService.startSpeaking(with: textView.text!)
            didStartSpeaking = true
        } else {
            speechService.pauseSpeaking()
        }
    }
    
    func liveButtonAction() {
        speechService.synthesizer.delegate = self
        updateLiveButtonImage()
        didStartSpeaking = false
        if pauseButtonState {
            captureFrame = true
            self.circularProgressBarView.alpha = 1
            speechButton.removeFromSuperview()
            emojiImageView.removeFromSuperview()
            speechService.stopSpeaking()
        } else {
            captureFrame = false
            UIView.transition(with: circularProgressBarView, duration: 0.5,
                              options: [.curveEaseOut],
                              animations: {
                self.circularProgressBarView.alpha = 0
                self.setupSpeechButton()
            })
        }
    }
    
    func updateLiveButtonImage() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let largeBoldButton = UIImage(systemName: pauseButtonState ? "pause" : "play.fill", withConfiguration: largeConfig)
        liveButton.setImage(largeBoldButton, for: .normal)
    }
    
    func setUpCircularProgressBarView() {
        circularProgressBarView = CircularProgressBarView()
        circularProgressBarView.center = view.center
        
        view.addSubview(circularProgressBarView)
        circularProgressBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circularProgressBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            circularProgressBarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularProgressBarView.heightAnchor.constraint(equalToConstant: 80),
            circularProgressBarView.widthAnchor.constraint(equalToConstant: 80)
        ])
        view.bringSubviewToFront(liveButton)
        circularProgressBarView.createCircularPath(with: CGPoint(x: 40, y: 40))
        progressAnimation(duration: circularViewDuration)
    }
    
    func progressAnimation(duration: TimeInterval) {
        CATransaction.begin()
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        CATransaction.setCompletionBlock { [weak self] in
            if self?.pauseButtonState ?? true {
                self?.captureFrame = true
            }
            self?.progressAnimation(duration: self!.circularViewDuration)
        }
        circularProgressBarView.progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
        CATransaction.commit()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if captureFrame {
            captureFrame = false
            if let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
                let image = ciimage.toUIImage()
                requestToDetectText(with: image.fixOrientation)
            }
        }
    }
    
    func stop() {
        guard captureSession.isRunning else {return}
        self.captureSession.stopRunning()
    }
    
    func resume() {
        guard !self.captureSession.isRunning else {return}
        self.captureSession.startRunning()
    }
    
    func requestToDetectText(with image: UIImage) {
        textDetection.recognizeText(with: image) { text in
            var correctedText : String = ""
            var emojiStr : String = "😶"
            if text.isEmpty {
                self.cyclesWithoutTextDetection += 1
            } else {
                self.cyclesWithoutTextDetection = 0
                correctedText = self.languageProcessor.getCorrectedText(for: text)
                emojiStr = self.languageProcessor.getEmojiSentiment(with: text)
            }
            
            DispatchQueue.main.async {
                if self.cyclesWithoutTextDetection > 2 {
                    self.instructionViewTimer()
                    self.cyclesWithoutTextDetection = 0
                }
                self.emojiImageView.image = emojiStr.toImage() ?? "⚠️".toImage()
                self.textView.text = correctedText
            }
        }
    }
    
    func quitLiveDetectionAction() {
        speechService.stopSpeaking()
        speechRecognizer.stopRecognizingSpeech()
        navigationController?.popViewController(animated: true)
    }
    
}

extension LiveCameraVC : AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttributes([.backgroundColor: UIColor.systemYellow, .font: UIFont.systemFont(ofSize: 17, weight: .regular)], range: characterRange)
        textView.attributedText = mutableAttributedString
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.textColor = .white
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        textView.attributedText = NSAttributedString(string: utterance.speechString)
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
}

extension LiveCameraVC : SpeechRecognizerDelegate {
    func didSayCorrectKeyword(for keyword: KeyWords) {
        if keyword == .start {
            pauseButtonState = true
            liveButtonAction()
            
        } else if keyword == .stop {
            pauseButtonState = false
            liveButtonAction()
            
        } else if keyword == .readToMe {
            speechService.stopSpeaking()
            didStartSpeaking = false
            isSpeaking = true
            speechActions()
            
        } else if keyword == .quitLiveDetection {
            quitLiveDetectionAction()
        }
        speechRecognizer.recognizeSpeech()
    }
}

//MARK: - Set up intial view
extension LiveCameraVC {
    
    func layoutElements() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.addSubview(tintView)
        view.addSubview(liveButton)
        view.addSubview(textView)
        
        setUpCircularProgressBarView()
        liveButton.addTarget(self, action: #selector(liveButtonTapped), for: .touchUpInside)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        tintView.translatesAutoresizingMaskIntoConstraints = false
        liveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tintView.topAnchor.constraint(equalTo: view.topAnchor),
            tintView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tintView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            liveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            liveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            liveButton.heightAnchor.constraint(equalToConstant: 80),
            liveButton.widthAnchor.constraint(equalToConstant: 80),
            
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: liveButton.topAnchor, constant: -10),
        
        ])
        
        
        view.addSubview(instructionView)
        instructionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instructionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            instructionView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        instructionView.configure(with: "Point at text", and: "Hold steady and orient device ", image: "rotate.left.fill")
        instructionViewTimer()
        
        view.layer.insertSublayer(previewLayer, below: tintView.layer)
        previewLayer.frame = self.view.layer.frame
    }
    
    func instructionViewTimer()  {
        instructionView.alpha = 1
        let _ = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(removeInstructionViewAction), userInfo: nil, repeats: false)
    }
    
    @objc func removeInstructionViewAction()  {
        UIView.transition(with: view, duration: 2, options: [.curveEaseOut]) {
            self.instructionView.alpha = 0
        } completion: { bool in
            
        }
    }
    
}
