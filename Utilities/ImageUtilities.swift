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
}

