//
//  UIImage+FUExtension.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/7.
//

import Foundation
import UIKit

extension UIImage {
    // Color & Size -> UIImage
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let imageRef = image?.cgImage else { return nil }
        self.init(cgImage: imageRef)
    }
    
    class func localizedImage(name: String) -> UIImage? {
        if let image = UIImage(named: name) {
            return image
        }
        let locale = NSLocale(localeIdentifier: NSLocale.current.identifier)
        let languageCode = locale.object(forKey: .languageCode)
        if let image = UIImage(named: String(format: "%@_%@", name, languageCode as! CVarArg)) {
            return image
        }
        return nil
    }
    
}
