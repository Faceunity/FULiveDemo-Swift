//
//  BeautyCache.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/18.
//

import UIKit

class BeautyCache {
    
    var skinParameters: [BeautyParameterModel]?
    var shapeParameters: [BeautyParameterModel]?
    var selectedFilter: BeautyFilterModel?
    var selectedStyle: BeautyStyleModel?
    
    static let shared = BeautyCache()
    
}
