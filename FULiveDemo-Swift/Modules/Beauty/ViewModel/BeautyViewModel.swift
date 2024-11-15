//
//  BeautyViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/13.
//

import FURenderKit
import UIKit

class BeautyViewModel: BaseViewModel {
    var beautySkinParams: [BeautySkinModel]!
    var beautyShapeParams: [BeautySkinModel]!
    var beautyFilters: [BeautyFilterModel]!
    var selectedFilter: BeautyFilterModel!
    
    /// 当前选中的功能项
    var selectedCategoryIndex: BeautyCategory = .none
    
    var beauty: FUBeauty!
    var performanceLevel: FUDevicePerformanceLevel?
    
    // MARK: Override properties
    
    override var isSupportMedia: Bool {
        return false
    }
    
    // MARK: Ovverride methods
    
    override init() {
        super.init()
        // 设置最大人脸数
        setMaxFaces(faceNumber: 4)
        // 设置人脸检测模式
        setFaceProcessorDetectMode(mode: FUFaceProcessorDetectModeVideo)
        // 获取设备性能等级
        performanceLevel = FURenderKit.devicePerformanceLevel()
        // 初始化FUBeauty
        if let path = Bundle.main.path(forResource: "face_beautification", ofType: "bundle") {
            beauty = FUBeauty(path: path, name: "FUBeauty")
            beauty.heavyBlur = 0
            // 默认均匀磨皮
            beauty.blurType = 3
            // 默认精细变形
            beauty.faceShape = 4
            
            // 高性能设备设置去黑眼圈、去法令纹、大眼、嘴形的最新效果
            let performanceLevel = FURenderKit.devicePerformanceLevel().rawValue
            if performanceLevel >= 2 {
                beauty.add(.mode2, forKey: .removePouchStrength)
                beauty.add(.mode2, forKey: .removeNasolabialFoldsStrength)
                beauty.add(.mode3, forKey: .eyeEnlarging)
                beauty.add(.mode3, forKey: .intensityMouth)
            }
        }
        
        if let params = BeautyCache.shared.skinParameters {
            beautySkinParams = params
        } else {
            beautySkinParams = skins()
        }
        
        if let params = BeautyCache.shared.shapeParameters {
            beautyShapeParams = params
        } else {
            beautyShapeParams = shapes()
        }
        beautyFilters = filters()

        if let filter = BeautyCache.shared.selectedFilter {
            selectedFilter = filter
        } else {
            selectedFilter = beautyFilters[1]
        }
    }
    
    override func loadItem() {
        FURenderKit.share().beauty = beauty
    }

    override func releaseItem() {
        FURenderKit.share().beauty = nil
    }
    
    // MARK: Instance methods
    
    /// 从本地读取缓存美颜
    func reloadBeautyParams() {
        for skin in beautySkinParams {
            setSkin(value: skin.currentValue, key: BeautySkin(rawValue: skin.type)!)
        }
        for shape in beautyShapeParams {
            setShape(value: shape.currentValue, key: BeautyShape(rawValue: shape.type)!)
        }
        if selectedFilter.index > 0 {
            setFilter(value: selectedFilter.value, name: selectedFilter.name)
        }
    }
    
    /// 缓存当前美颜
    func cacheBeautyParams() {
        BeautyCache.shared.skinParameters = beautySkinParams
        BeautyCache.shared.shapeParameters = beautyShapeParams
        BeautyCache.shared.selectedFilter = selectedFilter
        BeautyCache.shared.saveToCache()
    }
    
    /// 设置美肤属性值
    /// - Parameters:
    ///   - value: 值
    ///   - key: 美肤属性枚举值
    ///
    func setSkin(value: Double, key: BeautySkin) {
        guard let beauty = beauty else {
            return
        }
        switch key {
        case .blurLevel:
            beauty.blurLevel = value
        case .colorLevel:
            beauty.colorLevel = value
        case .redLevel:
            beauty.redLevel = value
        case .sharpen:
            beauty.sharpen = value
        case .eyeBright:
            beauty.eyeBright = value
        case .toothWhiten:
            beauty.toothWhiten = value
        case .removePouchStrength:
            beauty.removePouchStrength = value
        case .removeNasolabialFoldsStrength:
            beauty.removeNasolabialFoldsStrength = value
        case .faceThreed:
            beauty.faceThreed = value
        case .antiAcneSpot:
            beauty.antiAcneSpot = value
        case .clarity:
            beauty.clarity = value
        }
    }
    
    /// 设置美型属性值
    /// - Parameters:
    ///   - value: 值
    ///   - key: 美型属性枚举值
    func setShape(value: Double, key: BeautyShape) {
        guard let beauty = beauty else {
            return
        }
        switch key {
        case .cheekThinning:
            beauty.cheekThinning = value
        case .cheekV:
            beauty.cheekV = value
        case .cheekNarrow:
            beauty.cheekNarrow = value
        case .cheekShort:
            beauty.cheekShort = value
        case .cheekSmall:
            beauty.cheekSmall = value
        case .cheekbones:
            beauty.intensityCheekbones = value
        case .lowerJaw:
            beauty.intensityLowerJaw = value
        case .eyeEnlarging:
            beauty.eyeEnlarging = value
        case .eyeCircle:
            beauty.intensityEyeCircle = value
        case .chin:
            beauty.intensityChin = value
        case .forehead:
            beauty.intensityForehead = value
        case .nose:
            beauty.intensityNose = value
        case .mouth:
            beauty.intensityMouth = value
        case .canthus:
            beauty.intensityCanthus = value
        case .eyeSpace:
            beauty.intensityEyeSpace = value
        case .eyeRotate:
            beauty.intensityEyeRotate = value
        case .longNose:
            beauty.intensityLongNose = value
        case .philtrum:
            beauty.intensityPhiltrum = value
        case .smile:
            beauty.intensitySmile = value
        case .lipThick:
            beauty.intensityLipThick = value
        case .eyeHeight:
            beauty.intensityEyeHeight = value
        case .eyeLid:
            beauty.intensityEyeLid = value
        case .browHeight:
            beauty.intensityBrowHeight = value
        case .browSpace:
            beauty.intensityBrowSpace = value
        case .browThick:
            beauty.intensityBrowThick = value
        }
    }
    
    func setFilter(value: Double, name: String) {
        guard let beauty = beauty else {
            return
        }
        beauty.filterName = FUFilter(rawValue: name)
        beauty.filterLevel = value
    }
}

/// 获取初始数据
extension BeautyViewModel {
    // MARK: Beauty default datas
    
    private func skins() -> [BeautySkinModel] {
        let skinPath = performanceLevel!.rawValue <= 1 ?
            Bundle.main.path(forResource: "beauty_skin_low", ofType: "json") :
            Bundle.main.path(forResource: "beauty_skin", ofType: "json")
            
        guard let path = skinPath,
              let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        else {
            return []
        }
            
        do {
            let decoder = JSONDecoder()
            let skinModels = try decoder.decode([BeautySkinModel].self, from: data)
            return skinModels
        } catch {
            print("解码失败: \(error)")
            return []
        }
    }
    
    private func shapes() -> [BeautySkinModel] {
        let skinPath = performanceLevel!.rawValue <= 1 ?
            Bundle.main.path(forResource: "beauty_shape_low", ofType: "json") :
            Bundle.main.path(forResource: "beauty_shape", ofType: "json")
            
        guard let path = skinPath,
              let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        else {
            return []
        }
            
        do {
            let decoder = JSONDecoder()
            let shapeModels = try decoder.decode([BeautySkinModel].self, from: data)
            return shapeModels
        } catch {
            print("解码失败: \(error)")
            return []
        }
    }
    
    private func filters() -> [BeautyFilterModel] {
        let skinPath = Bundle.main.path(forResource: "beauty_filter", ofType: "json")
        guard let path = skinPath,
              let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        else {
            return []
        }
            
        do {
            let decoder = JSONDecoder()
            let results = try decoder.decode([BeautyFilterModel].self, from: data)
            return results
        } catch {
            print("解码失败: \(error)")
            return []
        }
    }
    
    private func setDefault(skins: [BeautySkinModel]) -> [BeautySkinModel] {
        for skin in skins {
            skin.currentValue = 0.0
        }
        return skins
    }
    
    private func setDefault(shapes: [BeautySkinModel]) -> [BeautySkinModel] {
        for shape in shapes {
            if shape.type == BeautyShape.chin.rawValue || shape.type == BeautyShape.forehead.rawValue || shape.type == BeautyShape.mouth.rawValue || shape.type == BeautyShape.eyeSpace.rawValue || shape.type == BeautyShape.eyeRotate.rawValue || shape.type == BeautyShape.longNose.rawValue || shape.type == BeautyShape.philtrum.rawValue {
                shape.currentValue = 0.5
            } else {
                shape.currentValue = 0.0
            }
        }
        return shapes
    }
}

extension BeautyViewModel {
    // MARK: Override FURenderKitDelegate
    
    override func renderKitWillRender(from renderInput: FURenderInput) {
        super.renderKitWillRender(from: renderInput)
        Manager.shared.updateBeautyBlurEffect()
    }

    override func renderKitDidRender(to renderOutput: FURenderOutput) {
        super.renderKitDidRender(to: renderOutput)
    }
}
