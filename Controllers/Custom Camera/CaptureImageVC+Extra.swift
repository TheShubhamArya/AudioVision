//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit
import AVFoundation

extension CaptureImageVC : UIGestureRecognizerDelegate {
    //MARK:- View Setup
    func setupView(){
        view.backgroundColor = .black
        view.addSubview(captureImageButton)
        view.addSubview(activityIndicator)
        view.addSubview(capturedImageView3)
        view.addSubview(capturedImageView2)
        view.addSubview(capturedImageView1)
        
        capturedImageView2.rotate(angle: 7.5)
        capturedImageView3.rotate(angle: 15)
        NSLayoutConstraint.activate([
            
            captureImageButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            captureImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            captureImageButton.widthAnchor.constraint(equalToConstant: 80),
            captureImageButton.heightAnchor.constraint(equalToConstant: 80),
            
            capturedImageView3.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            capturedImageView3.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            capturedImageView3.heightAnchor.constraint(equalToConstant: 150),
            capturedImageView3.widthAnchor.constraint(equalToConstant: 100),
            
            capturedImageView2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            capturedImageView2.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            capturedImageView2.heightAnchor.constraint(equalToConstant: 150),
            capturedImageView2.widthAnchor.constraint(equalToConstant: 100),
            
            capturedImageView1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            capturedImageView1.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            capturedImageView1.heightAnchor.constraint(equalToConstant: 150),
            capturedImageView1.widthAnchor.constraint(equalToConstant: 100),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50),
            activityIndicator.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(capturedImageTapped))
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(capturedImageSwipped(_ :)))
        rightGesture.direction = .right
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(capturedImageSwipped(_ :)))
        leftGesture.direction = .left
        let downGesture = UISwipeGestureRecognizer(target: self, action: #selector(capturedImageSwipped(_:)))
        downGesture.direction = .down
        
        capturedImageView1.isUserInteractionEnabled = true
        capturedImageView1.addGestureRecognizer(tapGestureRecognizer)
        capturedImageView1.addGestureRecognizer(rightGesture)
        capturedImageView1.addGestureRecognizer(leftGesture)
        capturedImageView1.addGestureRecognizer(downGesture)
        captureImageButton.addTarget(self, action: #selector(captureButtonTapped(_:)), for: .touchUpInside)
    }
    
    //MARK:- Permissions
    func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            return
        case .denied:
            abort()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
                                            { (authorized) in
                if(!authorized){
                    abort()
                }
            })
        case .restricted:
            abort()
        @unknown default:
            fatalError()
        }
    }
}

extension UIView {

    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }

}
