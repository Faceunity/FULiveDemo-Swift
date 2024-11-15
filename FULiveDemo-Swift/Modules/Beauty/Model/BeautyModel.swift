//
//  BeautyModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/13.
//

import Foundation

/// 美肤&美型
class BeautySkinModel: Codable {
    var name: String!
    
    /// 属性类型
    var type: Int!
    
    /// 皮肤分割（皮肤美白），YES开启，NO关闭，默认NO
    /// @note 开启时美白效果仅支持皮肤区域，关闭时美白效果支持全局区域
    /// @note 推荐非直播场景和 iPhoneXR 以上机型使用
    var enableSkinSegmentation: Bool = false
    
    /// 当前值
    var currentValue: Double!
    
    /// 默认值
    var defaultValue: Double!
    
    /// 默认值是否在中间
    var defaultValueInMiddle: Bool! = false
    
    /// 滑动条数值倍率
    var ratio: Float! = 1
    
    /// 设备性能
    var performanceLevel: Int = 1

    // 如果JSON中的键名与属性名不一致，可以使用CodingKeys来映射
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case currentValue
        case defaultValue
        case defaultValueInMiddle
        case ratio
        case performanceLevel
    }
}

/// 滤镜
class BeautyFilterModel: Codable {
    var name: String!
    var value: Double!
    var index: Int!
    
    // 如果JSON中的键名与属性名不一致，可以使用CodingKeys来映射
    enum CodingKeys: String, CodingKey {
        case name = "filterName"
        case index = "filterIndex"
        case value = "filterLevel"
    }
}
