//
//  LiveDefine.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/13.
//

import Foundation
import UIKit

func HeightIncludeBottomSafeArea(height: CGFloat) -> CGFloat {
    var height = height
    if #available(iOS 11.0, *) {
        height += (UIApplication.shared.keyWindow!.safeAreaInsets.bottom)
    }
    return height
}

func CurrentDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYYMMddhhmmssSS"
    let date = Date()
    return formatter.string(from: date)
}
