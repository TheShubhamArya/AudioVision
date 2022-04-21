//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/15/22.
//

import UIKit

// MARK: - CIImage Extension
extension CIImage {
    convenience init(_ image: UIImage) {
        self.init(cgImage: image.cgImage!)
    }
    
    func toUIImage() -> UIImage {
         let context = CIContext(options: nil)
         let cgImage = context.createCGImage(self, from: self.extent)!
        let image = UIImage(cgImage: cgImage).fixOrientation
         return image
    }
}

