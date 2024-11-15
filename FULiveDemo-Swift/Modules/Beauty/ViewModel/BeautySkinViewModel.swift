//
//  BeautyParametersViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/15.
//

import UIKit

class BeautySkinViewModel: NSObject {
    
    var beautyParameters: [BeautySkinModel]!
    /// 当前选中索引，-1为没有选中
    var selectedIndex: Int!
    
    var isDefaultValue: Bool {
        get {
            for model in beautyParameters {
                if fabs(model.currentValue - model.defaultValue) > 0.01 {
                    return false
                }
            }
            return true
        }
    }
    
    init(parameters: [BeautySkinModel], index: Int = -1) {
        
        super.init()
        
        beautyParameters = parameters
        selectedIndex = index
        
    }
    
    func setParametersToDefaults() {
        for model in beautyParameters {
            model.currentValue = model.defaultValue
        }
    }
    
    // 是否设置了人脸分割
    func enableSkinSegmentation() -> Bool {
        for model in beautyParameters {
            if model.type == BeautySkin.colorLevel.rawValue {
                return model.enableSkinSegmentation
            }
        }
        return false
    }
}
