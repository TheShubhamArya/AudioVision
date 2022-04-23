//
//  ImageStitcherVC.swift
//  
//
//  Created by Shubham Arya on 4/20/22.
//

import UIKit
import AVKit
import SwiftUI

class ImageStitcherVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession : AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .iFrame960x540
        return captureSession
    }()

    var captureFrame = true
    var isSpeaking = false
    var didStartSpeaking = false
    var isPaused = false
    
    private var registrationMechanism = ImageStitcher.Mechanism.homographic
    let textDetection = TextDetector()
    let languageProcessor = LanguageProcessor()
    let speechRecognizer = SpeechRecognizer()
    var alignedImage = UIImage()
    
    private let tintView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private let playButton : UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .semibold, scale: .medium)
        let largeBoldDoc = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
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
    
    let activityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .gray
        return activityIndicator
    }()
    
    var circularProgressAnimation : CABasicAnimation!
    var circularProgressBarView: CircularProgressBarView!
    var circularViewDuration: TimeInterval = 5
    var frameCounter = 0
    var capturedFrames = [CIImage]()
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        stop()
    }
    
    func setupSpeechButton() {
        view.addSubview(speechButton)
        view.addSubview(emojiImageView)
        NSLayoutConstraint.activate([
            emojiImageView.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -20),
            emojiImageView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            emojiImageView.heightAnchor.constraint(equalToConstant: 60),
            emojiImageView.widthAnchor.constraint(equalToConstant: 60),
            
            speechButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 20),
            speechButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            speechButton.heightAnchor.constraint(equalToConstant: 80),
            speechButton.widthAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    func layoutStackView() {
        UIView.transition(with: circularProgressBarView, duration: 3.0,
                          options: [.curveEaseOut],
                          animations: {
            self.circularProgressBarView.alpha = 0
        })
    }
    
    
    @objc func helpButtonTapped() {
        let vc = ImageStitcherHelpView()
        let host = UIHostingController(rootView: vc)
        present(host, animated: true, completion: nil)
    }
    
    @objc func playButtonTapped() {
        isPaused = !isPaused
        updatePlayButtonImage()
        playButtonAction()
    }
    
    func playButtonAction() {
        if isPaused {
            UIView.transition(with: tintView, duration: 2, options: [.curveEaseOut]) {
                self.tintView.alpha = 0
            } completion: { bool in
                self.circularProgressBarView.alpha = 1
                self.resume()
                self.frameCounter = 0
                self.capturedFrames = []
                let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startProgressAnimation), userInfo: nil, repeats: false)
            }
            
        } else  {
            updateUIWhenCaptureEnds()
        }
    }
    
    @objc func startProgressAnimation() {
        progressAnimation(duration: circularViewDuration)
    }
    
    func updatePlayButtonImage() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let largeBoldButton = UIImage(systemName: isPaused ? "pause" : "play.fill", withConfiguration: largeConfig)
        playButton.setImage(largeBoldButton, for: .normal)
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
        view.bringSubviewToFront(playButton)
        circularProgressBarView.createCircularPath(with: CGPoint(x: 40, y: 40))
    }
    
    func progressAnimation(duration: TimeInterval) {
        CATransaction.begin()
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        CATransaction.setCompletionBlock { [weak self] in
            if self!.isPaused {
                self?.updateUIWhenCaptureEnds()
            }
            
        }
        circularProgressBarView.progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
        CATransaction.commit()
    }
    
    func updateUIWhenCaptureEnds() {
        layoutStackView()
        isPaused = false
        updatePlayButtonImage()
        if capturedFrames.count == 1 {
            let uiimage = UIImage(ciImage: capturedFrames.first!)
            requestToDetectText(with: uiimage)
            
        } else if !capturedFrames.isEmpty {
            activityIndicator.startAnimating()
            stitchImages(count: 1)
        }
        
        UIView.transition(with: tintView, duration: 2, options: [.curveEaseOut]) {
            self.tintView.alpha = 0.85
        } completion: { bool in
            
        }
    }
    
    func stitchImages(count : Int) {
        if count > capturedFrames.count - 1 {
            requestToDetectText(with: alignedImage.rotate())
            return
        }
        
        print("currently on image ", count)
        ImageStitcher.shared.register(ciFloatingImage: capturedFrames[count], ciReferenceImage: capturedFrames[count - 1], registrationMechanism: registrationMechanism) { composite, error  in
            if error != nil {
                self.capturedFrames[count] = CIImage(image: self.alignedImage) ?? self.capturedFrames[count]
                self.stitchImages(count: count + 1)
                
            } else {
                self.alignedImage = composite
                self.capturedFrames[count] = CIImage(image: self.alignedImage) ?? self.capturedFrames[count]
                self.stitchImages(count: count + 1)
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if isPaused {
            if frameCounter % 10 == 0 {
                print("frame counter is \(frameCounter)")
                if let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
                    
                    capturedFrames.append(ciimage)
                }
            }
        }
        frameCounter += 1
    }
    
    func requestToDetectText(with image: UIImage) {
        textDetection.recognizeText(with: image) { text in
            
            let correctedText = self.languageProcessor.getCorrectedText(for: text)
            
            
            let emojiStr = self.languageProcessor.getEmojiSentiment(with: text)
            let emojiImage = emojiStr.toImage() ?? "⚠️".toImage()
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                let stitchedImageView = StitchedImageView(stitchedImage: image, detectText: correctedText, emojiImage: emojiImage!)
                let host = UIHostingController(rootView: stitchedImageView)
                self.present(host, animated: true)
                
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
    
}


extension ImageStitcherVC : SpeechRecognizerDelegate {
    func didSayCorrectKeyword(for keyword: KeyWords) {
        speechRecognizer.stopRecognizingSpeech()
        if keyword == .stop {
            isPaused = false
            updatePlayButtonImage()
            playButtonAction()
        } else if keyword == .start {
            isPaused = true
            updatePlayButtonImage()
            playButtonAction()
        } else if keyword == .quitImageStitching {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        speechRecognizer.recognizeSpeech()
    }
}

//MARK: - Set up intial view
extension ImageStitcherVC {
    
    func layoutElements() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.addSubview(tintView)
        view.addSubview(playButton)
        view.addSubview(instructionView)
        setUpCircularProgressBarView()
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        tintView.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        instructionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tintView.topAnchor.constraint(equalTo: view.topAnchor),
            tintView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tintView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            
            instructionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            instructionView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        instructionView.configure(with: "Point at text and slowly move from UP to DOWN", and: "This creates a long image to fit more text. Keep camera steady and orient device ", image: "ipad")
        view.layer.insertSublayer(previewLayer, below: tintView.layer)
        previewLayer.frame = self.view.layer.frame
        let _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(removeInstructionViewAction), userInfo: nil, repeats: false)
    }
    
    @objc func removeInstructionViewAction()  {
        UIView.transition(with: view, duration: 2, options: [.curveEaseOut]) {
            self.instructionView.alpha = 0
        } completion: { bool in
            
        }
    }
}
