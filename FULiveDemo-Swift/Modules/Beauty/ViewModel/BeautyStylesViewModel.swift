//
//  BeautyStyleViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/18.
//

import UIKit

class BeautyStylesViewModel: NSObject {
    var beautyStyles: [BeautyStyleModel]!
    /// 当前选中索引
    var selectedIndex: Int!
    
    init(styles: [BeautyStyleModel], index: Int = 0) {
        super.init()
        
        beautyStyles = styles
        selectedIndex = index
    }
}
