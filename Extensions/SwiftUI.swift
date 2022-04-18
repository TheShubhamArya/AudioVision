//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/15/22.
//

import UIKit
import SwiftUI

extension UIApplication {
    class func kTopViewController(controller: UIViewController? = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return kTopViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return kTopViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return kTopViewController(controller: presented)
        }
        return controller
    }
}
