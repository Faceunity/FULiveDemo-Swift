//
//  BeautyModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/13.
//

import Foundation

/// 美肤&美型
class BeautyParameterModel {
    
    var name: String!
    
    /// 属性类型
    var type: Int!
    
    /// 当前值
    var currentValue: Double!
    
    /// 默认值
    var defaultValue: Double!
    
    /// 默认值是否在中间
    var defaultValueInMiddle: Bool! = false
    
    /// 滑动条数值倍率
    var ratio: Float! = 1
}

/// 滤镜
class BeautyFilterModel {
    var name: String!
    var value: Double!
    var index: Int!
    
    init(name: String, value: Double, index: Int) {
        self.name = name
        self.value = value
        self.index = index
    }
}

/// 风格推荐（定制的美肤、美型、滤镜）
class BeautyStyleModel {
    var name: String!
    var skinParameters: [BeautyParameterModel]?
    var shapeParameters: [BeautyParameterModel]?
    var filter: BeautyFilterModel?
    var index: Int!
}
