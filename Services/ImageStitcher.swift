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
    
    // This is a CIContext for image rendering.
    private let context = CIContext()
    
    private init() {}
    
    /// Contains cases that correspond to different mechanism types for image registration.
    enum Mechanism: String, CaseIterable {
        
        case translational
        case homographic
        // This is a string that describes the case name.
        var label: String { rawValue.capitalized }
    }
    
    // MARK: Vision Functions
    
    ///- Tag: Register
    func register(ciFloatingImage: CIImage,
                  ciReferenceImage: CIImage,
                  registrationMechanism: ImageStitcher.Mechanism,
                  _ completion: @escaping (_ compositedImage: UIImage,_ error: Error?) -> Void) {
        
        let uiFloatingImage = UIImage(ciImage: ciFloatingImage).fixOrientation
        let uiReferenceImage = UIImage(ciImage: ciReferenceImage).fixOrientation.resizeImage(targetSize: uiFloatingImage.size)
        
        let ciRefImage = CIImage(image: uiReferenceImage) ?? ciReferenceImage
        let ciFloatImage = CIImage(image: uiFloatingImage) ?? ciFloatingImage
        
        // Let the Vision work take place on another queue, but hop back onto the main queue to record the results.
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Create the request handler with the reference image.
            let imageRequestHandler = VNImageRequestHandler(ciImage: ciRefImage)
            
            let request: VNImageRegistrationRequest
            
            // Create the registration request depending on the registration mechanism using the floating image.
            switch registrationMechanism {
            case .translational:
                request = VNTranslationalImageRegistrationRequest(targetedCIImage: ciFloatImage)
                
            case .homographic:
                request = VNHomographicImageRegistrationRequest(targetedCIImage: ciFloatImage)
            }
            
            // Perform the registration request.
            do {
                try imageRequestHandler.perform([request])
            } catch {
                print("oops something has gone wrong")
                print(error.localizedDescription)
                completion(uiReferenceImage, Error.requestHandler)
            }
            
            // Hop back onto the main queue to handle the results of the registration request.
            DispatchQueue.main.async {
                
                guard let alignmentObservation = request.results?.first as? VNImageAlignmentObservation else { return }
                
                let ciAlignedImage = self.makeAlignedImage(floatingImage: ciFloatImage, alignmentObservation: alignmentObservation)
                
                // Composites the aligned image on top of the reference image.
                let composite = ciAlignedImage.composited(over: ciRefImage)
                            
                // Convert the composited CIImage to PlatformImage (either NSImage or UIImage, depending on the platform).
                let cgComposite = self.context.createCGImage(composite, from: composite.extent)!
                let compositeImage = UIImage(cgImage: cgComposite)
                
                // Call the completion handler with the compositeImage and the paddedReferenceImage.
                completion(compositeImage, nil)
            }
        }
    }
    
    
    ///- Tag: MakeAlignedImage
    private func makeAlignedImage(floatingImage: CIImage, alignmentObservation: VNImageAlignmentObservation) -> CIImage {
        
        let alignedImage: CIImage
        
        // Apply the image alignment transform to the floating image.
        if let translationObservation = alignmentObservation as? VNImageTranslationAlignmentObservation {
            
            // Creates an alignedImage by transforming the floatingImage using the translational alignment transform.
            alignedImage = floatingImage.transformed(by: translationObservation.alignmentTransform)
            
        } else if let homographicObservation = alignmentObservation as? VNImageHomographicAlignmentObservation {
            
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
    
    // MARK: Geometry Utilities
    
    /// This is a quadrilateral defined by four corner points.
    private struct Quad {
        let topLeft: CGPoint
        let topRight: CGPoint
        let bottomLeft: CGPoint
        let bottomRight: CGPoint
    }
    
    /// Transforms the input point using the provided warpTransform matrix.
    private func warpedPoint(_ point: CGPoint, using warpTransform: simd_float3x3) -> CGPoint {
        let vector0 = SIMD3<Float>(x: Float(point.x), y: Float(point.y), z: 1)
        let vector1 = warpTransform * vector0
        return CGPoint(x: CGFloat(vector1.x / vector1.z), y: CGFloat(vector1.y / vector1.z))
    }
    
    /// Warps the input rectangle using the warpTransform matrix, and returns the warped Quad.
    private func makeWarpedQuad(for rect: CGRect, using warpTransform: simd_float3x3) -> Quad {
        let minX = rect.minX
        let maxX = rect.maxX
        let minY = rect.minY
        let maxY = rect.maxY
        
        let topLeft = CGPoint(x: minX, y: maxY)
        let topRight = CGPoint(x: maxX, y: maxY)
        let bottomLeft = CGPoint(x: minX, y: minY)
        let bottomRight = CGPoint(x: maxX, y: minY)
        
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

extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
       
       // Actually do the resizing to the rect using the ImageContext stuff
       UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
       self.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       return newImage!
   }

}
