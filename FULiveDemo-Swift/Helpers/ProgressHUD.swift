//
//  ProgressHUD.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/19.
//

import Foundation
import SVProgressHUD

class ProgressHUD {
    class func showInfo(message: String, delay: TimeInterval = 1.5) {
        SVProgressHUD.showInfo(withStatus: message)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setForegroundColor(.white)
        SVProgressHUD.setBackgroundColor(UIColor(white: 0, alpha: 0.74))
        SVProgressHUD.setBackgroundLayerColor(.clear)
        SVProgressHUD.setCornerRadius(5)
        SVProgressHUD.dismiss(withDelay: delay)
    }
    
    class func showError(message: String, delay: TimeInterval = 1.5) {
        SVProgressHUD.showError(withStatus: message)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setForegroundColor(.white)
        SVProgressHUD.setBackgroundColor(UIColor(white: 0, alpha: 0.74))
        SVProgressHUD.setBackgroundLayerColor(.clear)
        SVProgressHUD.setCornerRadius(5)
        SVProgressHUD.dismiss(withDelay: delay)
    }
    
    class func showSuccess(message: String, delay: TimeInterval = 1.5) {
        SVProgressHUD.showSuccess(withStatus: message)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setForegroundColor(.white)
        SVProgressHUD.setBackgroundColor(UIColor(white: 0, alpha: 0.74))
        SVProgressHUD.setBackgroundLayerColor(.clear)
        SVProgressHUD.setCornerRadius(5)
        SVProgressHUD.dismiss(withDelay: delay)
    }
}
