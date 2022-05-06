//
//  UIColor+FUExtension.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/6.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(redValue: CGFloat, greenValue: CGFloat, blueValue: CGFloat, alphaValue: CGFloat = 1.0) {
        self.init(red: redValue/255.0, green: greenValue/255.0, blue: blueValue/255.0, alpha: alphaValue)
    }
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
         
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        if hexString.hasPrefix("0x") || hexString.hasPrefix("0X") {
            scanner.scanLocation = 2
        }
         
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
         
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
         
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
         
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var hexString: String? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        
        let multiplier = 255.999999;
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(format: "#%02lX%02lX%02lX", Int(red * multiplier), Int(green * multiplier), Int(blue * multiplier))
        } else {
            return String(format: "#%02lX%02lX%02lX%02lX", Int(red * multiplier), Int(green * multiplier), Int(blue * multiplier), Int(alpha * multiplier))
        }
    }
}
