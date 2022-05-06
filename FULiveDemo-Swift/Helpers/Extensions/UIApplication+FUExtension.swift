//
//  UIApplication+FUExtension.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/18.
//

import Foundation
import UIKit

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabBarController = controller as? UITabBarController {
            if let selectedController = tabBarController.selectedViewController {
                return topViewController(controller: selectedController)
            }
        }
        if let presentedController = controller?.presentedViewController {
            return topViewController(controller: presentedController)
        }
        return controller
    }
}
