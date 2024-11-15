//
//  HomepageViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/6.
//

import FURenderKit
import UIKit

class HomepageViewModel: NSObject {
    var homepageDataSource: [[HomepageModel]] = []
    
    override init() {
        super.init()
        
        loadDataSource()
    }
    
    private func loadDataSource() {
        // 本地plist文件解析
        guard let path = Bundle.main.path(forResource: "dataSource", ofType: "plist"),
              let jsonArray = NSArray(contentsOfFile: path) as? [[Any]] else { return }
        
        // 获取SDK的ModuleCode
        let moduleCode0 = Int(FURenderKit.getModuleCode(0))
        let moduleCode1 = Int(FURenderKit.getModuleCode(1))
        
        // 将 plist 数据转换为 JSON Data
        for array in jsonArray {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: array),
                  var modules = try? JSONDecoder().decode([HomepageModel].self, from: jsonData) else { continue }
            
            // 更新模块启用状态
            for index in 0 ..< modules.count {
                var model = modules[index]
                model.modules?.forEach { code in
                    if model.moduleCode == 0 {
                        model.enabled = moduleCode0 & code > 0
                    } else {
                        model.enabled = moduleCode1 & code > 0
                    }
                }
                modules[index] = model
            }
            homepageDataSource.append(modules)
        }
    }
        
    private func updateModelCodeEnable(model: inout HomepageModel, code0: Int, code1: Int) {
        model.modules?.forEach { code in
            if model.moduleCode == 0 {
                model.enabled = code0 & code > 0
            } else {
                model.enabled = code1 & code > 0
            }
        }
    }
}
