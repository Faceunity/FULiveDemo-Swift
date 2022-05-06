//
//  HomepageViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/6.
//

import UIKit
import FURenderKit
import CoreMIDI

class HomepageViewModel: NSObject {
    
    var homepageDataSource: Array<Array<HomepageModel>> = []
    
    override init() {
        super.init()
        
        loadDataSource()
    }
    
    private func loadDataSource() {
        // 本地plist文件解析
        guard let path = Bundle.main.path(forResource: "dataSource", ofType: "plist") else { return }
        let jsonArray = NSArray(contentsOfFile: path) as! Array<Array<Any>>
        // 获取SDK的ModuleCode
        let moduleCode0: Int = Int(FURenderKit.getModuleCode(0))
        let moduleCode1: Int = Int(FURenderKit.getModuleCode(1))
        jsonArray.forEach { array in
            var modules = [HomepageModel].deserialize(from: array)
            for index in 0..<modules!.count {
                var model = modules![index]
                model?.modules?.forEach({ code in
                    // 权限码：分前32位和后32位 不同功能需要区别判断下
                    if model?.moduleCode == 0 {
                        model?.enabled = moduleCode0 & code > 0
                    } else {
                        model?.enabled = moduleCode1 & code > 0
                    }
                });
                modules![index] = model
            }
            homepageDataSource.append(modules as! [HomepageModel])
        }
    }
    
    private func updateModelCodeEnable(model: inout HomepageModel, code0: Int, code1: Int) {
        model.modules?.forEach({ code in
            if model.moduleCode == 0 {
                model.enabled = code0 & code > 0
            } else {
                model.enabled = code1 & code > 0
            }
        })
    }
}
