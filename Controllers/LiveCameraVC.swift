//
//  LiveCameraVC.swift
//  
//
//  Created by Shubham Arya on 4/11/22.
//

import UIKit
import AVKit
import Vision
import AVFoundation

class LiveCameraVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVSpeechSynthesizerDelegate {
    
    let synthesizer = AVSpeechSynthesizer()
    let captureSession = AVCaptureSession()

    let label = UILabel()
    var captureFrame = true
    
    private let tintView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    private let captureButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemRed
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        label.textColor = .label
        view.backgroundColor = .systemBackground
        captureSession.sessionPreset = .iFrame960x540
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.addSubview(tintView)
//        tintView.addSubview(label)
        
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        tintView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tintView.topAnchor.constraint(equalTo: view.topAnchor),
            tintView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tintView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
//            label.topAnchor.constraint(equalTo: tintView.topAnchor),
//            label.leadingAnchor.constraint(equalTo: tintView.leadingAnchor),
//            label.trailingAnchor.constraint(equalTo: tintView.trailingAnchor),
//            label.bottomAnchor.constraint(equalTo: tintView.bottomAnchor)
        ])
        view.addSubview(captureButton)
        view.addSubview(label)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            captureButton.heightAnchor.constraint(equalToConstant: 80),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        view.layer.insertSublayer(previewLayer, below: tintView.layer)
        previewLayer.frame = self.view.layer.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        stop()
    }
    
    func setupCaptureButton() {
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            captureButton.heightAnchor.constraint(equalToConstant: 80),
            captureButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if captureFrame {
            if let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
                let image = self.convert(cmage: ciimage)
                self.recognizeText(with: image)
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
    
    func convert(cmage: CIImage) -> UIImage {
         let context = CIContext(options: nil)
         let cgImage = context.createCGImage(cmage, from: cmage.extent)!
        let image = UIImage(cgImage: cgImage).fixOrientation
         return image
    }
    
    private func recognizeText(with image: UIImage?) {
        guard let cgImage = image?.cgImage else {return}
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        var recognizeTextRequest = VNRecognizeTextRequest()
        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.usesLanguageCorrection = true
        recognizeTextRequest = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                return
            }
            let filterObservation = observations.filter { obs in
                obs.confidence > 0.9
            }
            let text = filterObservation.compactMap ({
                $0.topCandidates(1).first?.string
            }).joined(separator: "\n")
            
            DispatchQueue.main.async {
                self.label.text = text
                self.captureFrame = true
            }
        }
        
        do {
            try handler.perform([recognizeTextRequest])
        } catch {
            print(error)
        }
    }
    
    func startSpeaking(with text: String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 10.0
        synthesizer.delegate = self
        synthesizer.speak(utterance)
    }
}
