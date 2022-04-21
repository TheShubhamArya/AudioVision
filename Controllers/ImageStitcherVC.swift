//
//  ImageStitcherVC.swift
//  
//
//  Created by Shubham Arya on 4/20/22.
//

import UIKit
import AVKit

class ImageStitcherVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession : AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .iFrame960x540
        return captureSession
    }()

    var captureFrame = true
    var isSpeaking = false
    var didStartSpeaking = false
    var pauseButtonState = false
    
    private var registrationMechanism = ImageStitcher.Mechanism.homographic
    let textDetection = TextDetector()
    let languageProcessor = LanguageProcessor()
    var alignedImage = UIImage()
    var displayImage = UIImageView()
    
    private let textView : UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textColor = .label
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let tintView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private let liveButton : UIButton = {
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
    
    private let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 10
        return stackView
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
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        stop()
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
    }
    
    func layoutStackView() {
        displayImage.contentMode = .scaleAspectFit
        view.addSubview(stackView)
        stackView.addArrangedSubview(displayImage)
        stackView.addArrangedSubview(textView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: liveButton.topAnchor, constant: -10)
        ])
        displayImage.image = alignedImage.rotate()
        UIView.transition(with: circularProgressBarView, duration: 3.0,
                          options: [.curveEaseOut],
                          animations: {
            self.circularProgressBarView.alpha = 0
        })
    }
    
    
    @objc func helpButtonTapped() {
//        let vc = LiveCameraHelpView()
//        let host = UIHostingController(rootView: vc)
//        present(host, animated: true, completion: nil)
    }
    
    @objc func liveButtonTapped() {
        pauseButtonState = !pauseButtonState

        updateLiveButtonImage()
        if pauseButtonState {
            tintView.alpha = 0
            displayImage.removeFromSuperview()
            circularProgressBarView.alpha = 1
            resume()
            frameCounter = 0
            capturedFrames = []
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startProgressAnimation), userInfo: nil, repeats: false)
            
            
        } else  {
//            stop()
            updateUIWhenCaptureEnds()
        }
    }
    
    @objc func startProgressAnimation() {
        progressAnimation(duration: circularViewDuration)
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
    }
    
    func progressAnimation(duration: TimeInterval) {
        CATransaction.begin()
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        CATransaction.setCompletionBlock { [weak self] in
            print("Animation is done do something again", Date())
//            self?.stop()
            self?.updateUIWhenCaptureEnds()
        }
        circularProgressBarView.progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
        CATransaction.commit()
    }
    
    func updateUIWhenCaptureEnds() {
        layoutStackView()
        pauseButtonState = false
        updateLiveButtonImage()
        activityIndicator.startAnimating()
        stitchImages(count: 1)
        UIView.transition(with: tintView, duration: 2, options: [.curveEaseOut]) {
            self.tintView.alpha = 0.85
        } completion: { bool in
            
        }
    }
    
    func stitchImages(count : Int) {
        if count > capturedFrames.count - 1 {
            displayImage.image = alignedImage.rotate()
            requestToDetectText(with: alignedImage.rotate())
            return
        }
        
        print("currently on image ", count)
        ImageStitcher.shared.register(ciFloatingImage: capturedFrames[count], ciReferenceImage: capturedFrames[count - 1], registrationMechanism: registrationMechanism) { composite, error  in
            if let error = error {
                print("error is ",error)
                self.capturedFrames[count] = CIImage(image: self.alignedImage) ?? self.capturedFrames[count]
                self.stitchImages(count: count + 1)
                
            } else {
                self.alignedImage = composite
                self.capturedFrames[count] = CIImage(image: self.alignedImage) ?? self.capturedFrames[count]

                DispatchQueue.main.async {
                    self.stitchImages(count: count + 1)
                }
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if pauseButtonState {
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
        print("request to text detection")
        textDetection.recognizeText(with: image) { text in
            
            let correctedText = self.languageProcessor.getCorrectedText(for: text)
            
            print("corrected text is ",correctedText)
            
            let emojiStr = self.languageProcessor.getEmojiSentiment(with: text)
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
//                self.emojiImageView.image = emojiStr.toImage() ?? "⚠️".toImage()
                self.textView.text = correctedText
                if correctedText.isEmpty {
                    self.textView.text = "No text detected"
                }
                
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

//MARK: - Set up intial view
extension ImageStitcherVC {
    
    func layoutElements() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.addSubview(tintView)
        view.addSubview(liveButton)
        view.addSubview(instructionView)
        setUpCircularProgressBarView()
        liveButton.addTarget(self, action: #selector(liveButtonTapped), for: .touchUpInside)
        
        tintView.translatesAutoresizingMaskIntoConstraints = false
        liveButton.translatesAutoresizingMaskIntoConstraints = false
        instructionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tintView.topAnchor.constraint(equalTo: view.topAnchor),
            tintView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tintView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            liveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            liveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            liveButton.heightAnchor.constraint(equalToConstant: 80),
            liveButton.widthAnchor.constraint(equalToConstant: 80),
            
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

extension UIImage {
    
    func rotate() -> UIImage {
        var rotatedImage = UIImage()
        guard let cgImage = cgImage else {
            print("could not rotate image")
            return self
        }
        switch imageOrientation {
        case .right:
            print("right")
            rotatedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .down)
        case .down:
            print("down")
            rotatedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .left)
        case .left:
            print("left")
            rotatedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        default:
            print("up")
            rotatedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .right)
        }
        
        return rotatedImage
    }
}
