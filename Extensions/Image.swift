//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import UIKit

extension UIImage {
    
    var fixOrientation : UIImage {
        if (self.imageOrientation == .up) {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
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

extension CIImage  {
    func convertCIImageToCGImage() -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(self, from: self.extent)
    }
}

