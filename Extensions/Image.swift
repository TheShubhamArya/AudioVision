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
    
}
