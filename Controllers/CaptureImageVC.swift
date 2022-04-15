//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit
import AVFoundation

protocol CapturedImageProtocol {
    func didReturnCapturedImages(with images: [UIImage])
}

class CaptureImageVC: UIViewController {

    var captureImageDelegate : CapturedImageProtocol!
    
    var captureSession : AVCaptureSession!
    let systemSoundID: SystemSoundID = 1108
    
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!
    
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    var videoOutput : AVCaptureVideoDataOutput!
    
    var takePicture = false
    var backCameraOn = true
    
    var capturedImages = [UIImage]()

    
    let captureImageButton : UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .bold, scale: .large)

        let largeBoldDoc = UIImage(systemName: "largecircle.fill.circle", withConfiguration: largeConfig)

        button.setImage(largeBoldDoc, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let capturedImageView1 = CaptureImageView()
    let capturedImageView2 = CaptureImageView()
    let capturedImageView3 = CaptureImageView()
    
    let speechRecognizer = SpeechRecognizer()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        speechRecognizer.speechRecognizerDelegate = self
        speechRecognizer.speechRecognitionAuthorization()
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//       get {
//          return .portrait
//       }
//    }
//    
//    override var shouldAutorotate: Bool {
//        return false
//    }
//
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return UIInterfaceOrientation.portrait
//    }
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        print("view will layout subviews")
//        setupView()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermissions()
        setupAndStartCaptureSession()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
    }
    
    @objc func doneAction() {
        print("done button tapped")
        speechRecognizer.stopRecognizingSpeech()
        captureImageDelegate.didReturnCapturedImages(with: capturedImages)
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Camera Setup
    func setupAndStartCaptureSession(){
        DispatchQueue.global(qos: .userInitiated).async{
            self.captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()
            
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            self.setupInputs()
            
            DispatchQueue.main.async {
                self.setupPreviewLayer()
            }
            
            self.setupOutput()
            
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    func setupInputs(){
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            fatalError("no back camera")
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else {
            fatalError("no front camera")
        }
        
        //now we need to create an input objects from our devices
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("could not create input device from back camera")
        }
        backInput = bInput
        if !captureSession.canAddInput(backInput) {
            fatalError("could not add back camera input to capture session")
        }
        
        guard let fInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("could not create input device from front camera")
        }
        frontInput = fInput
        if !captureSession.canAddInput(frontInput) {
            fatalError("could not add front camera input to capture session")
        }
        
        captureSession.addInput(backInput)
    }
    
    func setupOutput(){
        videoOutput = AVCaptureVideoDataOutput()
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("could not add video output")
        }
        
        videoOutput.connections.first?.videoOrientation = .portrait
    }
    
    func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, below: captureImageButton.layer)
        previewLayer.frame = self.view.layer.frame
    }
    
    func switchCameraInput(){
        //don't let user spam the button, fun for the user, not fun for performance
//        switchCameraButton.isUserInteractionEnabled = false
        
        captureSession.beginConfiguration()
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            backCameraOn = true
        }
        
        videoOutput.connections.first?.videoOrientation = .portrait
        
        videoOutput.connections.first?.isVideoMirrored = !backCameraOn
        
        captureSession.commitConfiguration()
    }
    
    //MARK:- Actions
    @objc func captureButtonTapped(_ sender: UIButton?){
        captureImageAction()
    }
    
    func captureImageAction() {
        speechRecognizer.stopRecognizingSpeech()
        takePicture = true
    }
    
    @objc func capturedImageTapped() {
        let vc = DisplayImageVC()
        vc.delegate = self
        vc.capturedImages = capturedImages
        vc.modalPresentationStyle = .popover
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func capturedImageSwipped(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            if capturedImages.count > 1 {
                let lastImage = capturedImages.removeLast()
                capturedImages.insert(lastImage, at: 0)
                updateCapturedImages()
            }
            break
        case .down:
            if capturedImages.count > 0 {
                capturedImages.removeLast()
                updateCapturedImages()
            }
            break
        case .left:
            if capturedImages.count > 1 {
                let lastImage = capturedImages.removeFirst()
                capturedImages.insert(lastImage, at: capturedImages.count)
                updateCapturedImages()
            }
            break
        case .up:
            print("Swiped up")
            break
        default:
            break
        }
    }
    
    func updateCapturedImages() {
        let imageCount = capturedImages.count
        capturedImageView1.alpha = 0
        capturedImageView2.alpha = 0
        capturedImageView3.alpha = 0
        
        if capturedImages.count >= 1 {
            capturedImageView1.alpha = 1
            capturedImageView1.image = capturedImages[imageCount - 1]
        }
        if self.capturedImages.count >= 2 {
            capturedImageView2.alpha = 1
            capturedImageView2.image = capturedImages[imageCount - 2]
        }
        if self.capturedImages.count >= 3 {
            capturedImageView3.alpha = 1
            capturedImageView3.image = capturedImages[imageCount - 3]
        }
    }

}

extension CaptureImageVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if !takePicture {
            return
        }
        
        self.takePicture = false
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        let image = UIImage(ciImage: ciImage)
        capturedImages.append(image)
        AudioServicesPlaySystemSound(systemSoundID)
        speechRecognizer.recognizeSpeech()
        DispatchQueue.main.async {
            self.updateCapturedImages()
        }
    }
        
}

extension CaptureImageVC : SpeechRecognizerDelegate {
    
    func didSayCorrectKeyword(for keyword: KeyWords) {
        if keyword == .takePicture {
            captureImageAction()
        } else if keyword == .done {
            print("done action")
            doneAction()
            return
        }
    }
    
}

extension CaptureImageVC : DisplayImageProtocol {
    
    func displayImageExited(afterEditing editedImages: [UIImage]) {
        capturedImages = editedImages
        updateCapturedImages()
    }
    
}
