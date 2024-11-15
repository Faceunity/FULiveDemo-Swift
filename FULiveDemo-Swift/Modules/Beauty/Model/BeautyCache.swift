//
//  BeautyCache.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/18.
//

import UIKit

class BeautyCache {
    
    var skinParameters: [BeautySkinModel]?
    var shapeParameters: [BeautySkinModel]?
    var selectedFilter: BeautyFilterModel?
    
    static let shared = BeautyCache()
    
    private let defaults = UserDefaults.standard
    private let skinParametersKey = "BeautyCache.skinParameters"
    private let shapeParametersKey = "BeautyCache.shapeParameters"
    private let selectedFilterKey = "BeautyCache.selectedFilter"
    
    private init() {
        loadFromCache()
    }
    
    // 保存数据到本地
    func saveToCache() {
        if let skinData = try? JSONEncoder().encode(skinParameters) {
            defaults.set(skinData, forKey: skinParametersKey)
        }
        
        if let shapeData = try? JSONEncoder().encode(shapeParameters) {
            defaults.set(shapeData, forKey: shapeParametersKey)
        }
        
        if let filterData = try? JSONEncoder().encode(selectedFilter) {
            defaults.set(filterData, forKey: selectedFilterKey)
        }
        
        defaults.synchronize()
    }
    
    // 从本地读取数据
    private func loadFromCache() {
        if let skinData = defaults.data(forKey: skinParametersKey) {
            skinParameters = try? JSONDecoder().decode([BeautySkinModel].self, from: skinData)
        }
        
        if let shapeData = defaults.data(forKey: shapeParametersKey) {
            shapeParameters = try? JSONDecoder().decode([BeautySkinModel].self, from: shapeData)
        }
        
        if let filterData = defaults.data(forKey: selectedFilterKey) {
            selectedFilter = try? JSONDecoder().decode(BeautyFilterModel.self, from: filterData)
        }
    }
    
    // 清除缓存
    func clearCache() {
        skinParameters = nil
        shapeParameters = nil
        selectedFilter = nil
        
        defaults.removeObject(forKey: skinParametersKey)
        defaults.removeObject(forKey: shapeParametersKey)
        defaults.removeObject(forKey: selectedFilterKey)
        defaults.synchronize()
    }
}
