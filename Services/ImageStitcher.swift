//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/15/22.
//

import UIKit
import Vision

enum Error {
    case requestHandler
}

class ImageStitcher {
    
    static let shared = ImageStitcher()

    private let context = CIContext()
    
    private init() {}
    
    func sew(with ciFloatingImage: CIImage,and ciReferenceImage: CIImage, _ completion: @escaping (_ compositedImage: UIImage,_ error: Error?) -> Void) {
        
        let uiFloatingImage = UIImage(ciImage: ciFloatingImage).fixOrientation
        let uiReferenceImage = UIImage(ciImage: ciReferenceImage).fixOrientation.resizeImage(targetSize: uiFloatingImage.size)
        
        let ciRefImage = CIImage(image: uiReferenceImage) ?? ciReferenceImage
        let ciFloatImage = CIImage(image: uiFloatingImage) ?? ciFloatingImage
        
    
        DispatchQueue.global(qos: .userInitiated).async {
            
            let imageRequestHandler = VNImageRequestHandler(ciImage: ciRefImage)
            
            let request: VNImageRegistrationRequest = VNHomographicImageRegistrationRequest(targetedCIImage: ciFloatImage)
            
            do {
                try imageRequestHandler.perform([request])
            } catch {
                print(error.localizedDescription)
                completion(uiReferenceImage, Error.requestHandler)
            }
            
            DispatchQueue.main.async {
                
                guard let alignmentObservation = request.results?.first as? VNImageAlignmentObservation else { return }
                
                let ciAlignedImage = self.makeAlignedImage(floatingImage: ciFloatImage, alignmentObservation: alignmentObservation)
                
                let composite = ciAlignedImage.composited(over: ciRefImage)
                            
                let cgComposite = self.context.createCGImage(composite, from: composite.extent)!
                
                let compositeImage = UIImage(cgImage: cgComposite)
                
                completion(compositeImage, nil)
            }
        }
    }
    
    
    ///- Tag: MakeAlignedImage
    private func makeAlignedImage(floatingImage: CIImage, alignmentObservation: VNImageAlignmentObservation) -> CIImage {
        
        let alignedImage: CIImage
        
        if let homographicObservation = alignmentObservation as? VNImageHomographicAlignmentObservation {
            
            let warpTransform = homographicObservation.warpTransform
            let quad = makeWarpedQuad(for: floatingImage.extent, using: warpTransform)
            
            // Creates the alignedImage by warping the floating image using the warpTransform from the homographic observation.
            let transformParameters = [
                "inputTopLeft": CIVector(cgPoint: quad.topLeft),
                "inputTopRight": CIVector(cgPoint: quad.topRight),
                "inputBottomRight": CIVector(cgPoint: quad.bottomRight),
                "inputBottomLeft": CIVector(cgPoint: quad.bottomLeft)
            ]
            
            alignedImage = floatingImage.applyingFilter("CIPerspectiveTransform", parameters: transformParameters)
            
        } else {
            fatalError("Unhandled VNImageAlignmentObservation type.")
        }
        
        return alignedImage
    }
    
    /// Geometry Utilities
    
    private struct Quad {
        let topLeft: CGPoint
        let topRight: CGPoint
        let bottomLeft: CGPoint
        let bottomRight: CGPoint
    }
    
    // Transforms the input point using the provided warpTransform matrix.
    private func warpedPoint(_ point: CGPoint, using warpTransform: simd_float3x3) -> CGPoint {
        let vector0 = SIMD3<Float>(x: Float(point.x), y: Float(point.y), z: 1)
        let vector1 = warpTransform * vector0
        return CGPoint(x: CGFloat(vector1.x / vector1.z), y: CGFloat(vector1.y / vector1.z))
    }
    
    // Warps the input rectangle using the warpTransform matrix, and returns the warped Quad.
    private func makeWarpedQuad(for rect: CGRect, using warpTransform: simd_float3x3) -> Quad {
        
        let topLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let topRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.minY)
        
        let warpedTopLeft = warpedPoint(topLeft, using: warpTransform)
        let warpedTopRight = warpedPoint(topRight, using: warpTransform)
        let warpedBottomLeft = warpedPoint(bottomLeft, using: warpTransform)
        let warpedBottomRight = warpedPoint(bottomRight, using: warpTransform)
        
        return Quad(topLeft: warpedTopLeft,
                    topRight: warpedTopRight,
                    bottomLeft: warpedBottomLeft,
                    bottomRight: warpedBottomRight)
    }
}
