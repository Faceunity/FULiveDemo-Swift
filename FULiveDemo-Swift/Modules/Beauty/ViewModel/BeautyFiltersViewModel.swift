//
//  BeautyFiltersViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/15.
//

import UIKit

class BeautyFiltersViewModel: NSObject {
    
    var beautyFilters: [BeautyFilterModel]!
    /// 当前选中索引
    var selectedIndex: Int!
    
    init(filters: [BeautyFilterModel], index: Int = 0) {
        super.init()
        
        beautyFilters = filters
        selectedIndex = index
    }
}
