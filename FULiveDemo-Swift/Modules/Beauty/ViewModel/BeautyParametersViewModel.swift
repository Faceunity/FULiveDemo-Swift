//
//  BeautyParametersViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/15.
//

import UIKit

class BeautyParametersViewModel: NSObject {
    
    var beautyParameters: [BeautyParameterModel]!
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
    
    init(parameters: [BeautyParameterModel], index: Int = -1) {
        
        super.init()
        
        beautyParameters = parameters
        selectedIndex = index
        
    }
    
    func setParametersToDefaults() {
        for model in beautyParameters {
            model.currentValue = model.defaultValue
        }
    }
}
