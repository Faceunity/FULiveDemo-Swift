//
//  BeautyViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/13.
//

import UIKit
import FURenderKit

class BeautyViewModel: BaseViewModel {
    
    var beautySkinParams: [BeautyParameterModel]!
    var beautyShapeParams: [BeautyParameterModel]!
    var beautyFilters: [BeautyFilterModel]!
    var selectedFilter: BeautyFilterModel!
    var beautyStyles: [BeautyStyleModel]!
    var selectedStyle: BeautyStyleModel!
    
    /// 当前选中的功能项
    var selectedCategoryIndex: BeautyCategory = .none
    
    var beauty: FUBeauty!
    var performanceLevel: FUDevicePerformanceLevel?
    
    //MARK: Override properties
    
    override var isSupportMedia: Bool {
        return false
    }
    
    //MARK: Ovverride methods
    
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
            beauty.heavyBlur = 0;
            // 默认均匀磨皮
            beauty.blurType = 3;
            // 默认精细变形
            beauty.faceShape = 4;
            
            // 高性能设备设置去黑眼圈、去法令纹、大眼、嘴形的最新效果
            if performanceLevel == .high {
                beauty.add(.mode2, forKey: .removePouchStrength)
                beauty.add(.mode2, forKey: .removeNasolabialFoldsStrength)
                beauty.add(.mode3, forKey: .eyeEnlarging)
                beauty.add(.mode3, forKey: .intensityMouth)
            }
        }
        
        beautySkinParams = skins()
        beautyShapeParams = shapes()
        beautyFilters = filters()
        selectedFilter = beautyFilters[2]
        beautyStyles = styles()
        selectedStyle = beautyStyles[0]
    }
    
    override func loadItem() {
        FURenderKit.share().beauty = beauty
    }

    override func releaseItem() {
        FURenderKit.share().beauty = nil
    }
    
    //MARK: Instance methods
    
    /// 从本地读取缓存美颜
    func reloadBeautyParams() {
        if let params = BeautyCache.shared.skinParameters {
            beautySkinParams = params
        }
        if let params = BeautyCache.shared.shapeParameters {
            beautyShapeParams = params
        }
        if let filter = BeautyCache.shared.selectedFilter {
            selectedFilter = filter
        }
        if let style = BeautyCache.shared.selectedStyle {
            selectedStyle = style
        }
        
        if selectedStyle != nil && selectedStyle.index > 0 {
            // 选中风格推荐，优先设置风格推荐效果
            setStyle(style: selectedStyle!)
        } else {
            for skin in beautySkinParams {
                self.setSkin(value: skin.currentValue, key: BeautySkin(rawValue: skin.type)!)
            }
            for shape in beautyShapeParams {
                self.setShape(value: shape.currentValue, key: BeautyShape(rawValue: shape.type)!)
            }
            if selectedFilter.index > 0 {
                setFilter(value: selectedFilter.value, name: selectedFilter.name)
            }
        }
    }
    
    /// 缓存当前美颜
    func cacheBeautyParams() {
        BeautyCache.shared.skinParameters = beautySkinParams
        BeautyCache.shared.shapeParameters = beautyShapeParams
        BeautyCache.shared.selectedFilter = selectedFilter
        if selectedStyle.index == 0 {
            BeautyCache.shared.selectedStyle = nil
        } else {
            BeautyCache.shared.selectedStyle = selectedStyle
        }
    }
    
    /// 设置美肤属性值
    /// - Parameters:
    ///   - value: 值
    ///   - key: 美肤属性枚举值
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
        case .cheekBones:
            beauty.intensityCheekbones = value
        case .lowerJaw:
            beauty.intensityLowerJaw = value
        case .eyeEnlarging:
            beauty.eyeEnlarging = value
        case .eyeCycle:
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
        }
    }
    
    func setFilter(value: Double, name: String) {
        guard let beauty = beauty else {
            return
        }
        beauty.filterName = FUFilter(rawValue: name)
        beauty.filterLevel = value
    }
    
    func setStyle(style: BeautyStyleModel) {
        // 风格推荐需要分别设置滤镜、美肤、美型
        if let filterModel = style.filter {
            setFilter(value: filterModel.value, name: filterModel.name)
        }
        if let skins = style.skinParameters {
            for skin in skins {
                setSkin(value: skin.currentValue, key: BeautySkin(rawValue: skin.type)!)
            }
        }
        if let shapes = style.shapeParameters {
            for shape in shapes {
                setShape(value: shape.currentValue, key: BeautyShape(rawValue: shape.type)!)
            }
        }
    }
    
    /// 更新磨皮效果
    func updateBeautyBlurEffect() {
        guard beauty != nil && beauty.enable != false  else { return }
        if performanceLevel == .high {
            // 高性能设备根据人脸置信度设置不同磨皮效果
            let score = FUAIKit.fuFaceProcessorGetConfidenceScore(0)
            if score > 0.95 {
                beauty.blurType = 3
                beauty.blurUseMask = true
            } else {
                beauty.blurType = 2
                beauty.blurUseMask = false
            }
        } else {
            // 低性能设备使用精细磨皮
            beauty.blurType = 2;
            beauty.blurUseMask = false
        }
    }
}

/// 获取初始数据
extension BeautyViewModel {
    
    //MARK: Beauty default datas
    
    private func skins() -> [BeautyParameterModel] {
        var results: [BeautyParameterModel] = []
        for index in 0...BeautySkin.removeNasolabialFoldsStrength.rawValue {
            let model = BeautyParameterModel()
            model.name = BeautySkin(rawValue: index)!.name
            model.type = index
            model.currentValue = BeautySkin(rawValue: index)!.defaultValue
            model.defaultValue = BeautySkin(rawValue: index)!.defaultValue
            model.defaultValueInMiddle = BeautySkin(rawValue: index)!.defaultValueInMiddle
            model.ratio = BeautySkin(rawValue: index)!.ratio
            results.append(model)
        }
        return results
    }
    
    private func shapes() -> [BeautyParameterModel] {
        var results: [BeautyParameterModel] = []
        for index in 0...BeautyShape.smile.rawValue {
            let model = BeautyParameterModel()
            model.name = BeautyShape(rawValue: index)!.name
            model.type = index
            model.currentValue = BeautyShape(rawValue: index)!.defaultValue
            model.defaultValue = BeautyShape(rawValue: index)!.defaultValue
            model.defaultValueInMiddle = BeautyShape(rawValue: index)!.defaultValueInMiddle
            model.ratio = BeautyShape(rawValue: index)!.ratio
            results.append(model)
        }
        return results
    }
    
    private func filters() -> [BeautyFilterModel] {
        let filterNames = ["origin",
                           "ziran1",
                           "ziran2",
                           "ziran3",
                           "ziran4",
                           "ziran5",
                           "ziran6",
                           "ziran7",
                           "ziran8",
                           "zhiganhui1",
                           "zhiganhui2",
                           "zhiganhui3",
                           "zhiganhui4",
                           "zhiganhui5",
                           "zhiganhui6",
                           "zhiganhui7",
                           "zhiganhui8",
                           "mitao1",
                           "mitao2",
                           "mitao3",
                           "mitao4",
                           "mitao5",
                           "mitao6",
                           "mitao7",
                           "mitao8",
                           "bailiang1",
                           "bailiang2",
                           "bailiang3",
                           "bailiang4",
                           "bailiang5",
                           "bailiang6",
                           "bailiang7",
                           "fennen1",
                           "fennen2",
                           "fennen3",
                           "fennen5",
                           "fennen6",
                           "fennen7",
                           "fennen8",
                           "lengsediao1",
                           "lengsediao2",
                           "lengsediao3",
                           "lengsediao4",
                           "lengsediao7",
                           "lengsediao8",
                           "lengsediao11",
                           "nuansediao1",
                           "nuansediao2",
                           "gexing1",
                           "gexing2",
                           "gexing3",
                           "gexing4",
                           "gexing5",
                           "gexing7",
                           "gexing10",
                           "gexing11",
                           "xiaoqingxin1",
                           "xiaoqingxin3",
                           "xiaoqingxin4",
                           "xiaoqingxin6",
                           "heibai1",
                           "heibai2",
                           "heibai3",
                           "heibai4"]
        var results: [BeautyFilterModel] = []
        for (index, filter) in filterNames.enumerated() {
            // 滤镜默认值都为0.4
            let model = BeautyFilterModel(name: filter, value: 0.4, index: index)
            results.append(model)
        }
        return results
    }
    
    private func setDefault(skins: [BeautyParameterModel]) -> [BeautyParameterModel] {
        for skin in skins {
            skin.currentValue = 0.0;
        }
        return skins
    }
    
    private func setDefault(shapes: [BeautyParameterModel]) -> [BeautyParameterModel] {
        for shape in shapes {
            if shape.type == BeautyShape.chin.rawValue || shape.type == BeautyShape.forehead.rawValue || shape.type == BeautyShape.mouth.rawValue || shape.type == BeautyShape.eyeSpace.rawValue || shape.type == BeautyShape.eyeRotate.rawValue || shape.type == BeautyShape.longNose.rawValue || shape.type == BeautyShape.philtrum.rawValue {
                shape.currentValue = 0.5
            } else {
                shape.currentValue = 0.0
            }
        }
        return shapes
    }
    
    private func styles() -> [BeautyStyleModel] {
        return [beautyStyle0(), beautyStyle1(), beautyStyle2(), beautyStyle3(), beautyStyle4(), beautyStyle5(), beautyStyle6(), beautyStyle7()]
    }
    
    private func beautyStyle0() -> BeautyStyleModel {
        let model = BeautyStyleModel()
        model.name = "style0"
        model.filter = nil
        model.skinParameters = nil
        model.shapeParameters = nil
        model.index = 0
        return model
    }
    
    private func beautyStyle1() -> BeautyStyleModel {
        let model = BeautyStyleModel()
        model.name = "style1"
        model.filter = BeautyFilterModel(name: "bailiang1", value: 0.2, index: -1)
        
        var skins: [BeautyParameterModel] = skins()
        skins = setDefault(skins: skins)
        skins[BeautySkin.colorLevel.rawValue].currentValue = 0.5
        skins[BeautySkin.blurLevel.rawValue].currentValue = 3.0
        skins[BeautySkin.eyeBright.rawValue].currentValue = 0.35
        skins[BeautySkin.toothWhiten.rawValue].currentValue = 0.25
        model.skinParameters = skins
        
        var shapes: [BeautyParameterModel] = shapes()
        shapes = setDefault(shapes: shapes)
        shapes[BeautyShape.cheekThinning.rawValue].currentValue = 0.45
        shapes[BeautyShape.cheekV.rawValue].currentValue = 0.08
        shapes[BeautyShape.cheekShort.rawValue].currentValue = 0.05
        shapes[BeautyShape.eyeEnlarging.rawValue].currentValue = 0.3
        model.shapeParameters = shapes
        
        model.index = 1
        
        return model
    }
    
    private func beautyStyle2() -> BeautyStyleModel {
        let model = BeautyStyleModel()
        model.name = "style2"
        model.filter = BeautyFilterModel(name: "ziran3", value: 0.35, index: -1)
        
        var skins: [BeautyParameterModel] = skins()
        skins = setDefault(skins: skins)
        skins[BeautySkin.colorLevel.rawValue].currentValue = 0.7
        skins[BeautySkin.redLevel.rawValue].currentValue = 0.3
        skins[BeautySkin.blurLevel.rawValue].currentValue = 3.0
        skins[BeautySkin.eyeBright.rawValue].currentValue = 0.5
        skins[BeautySkin.toothWhiten.rawValue].currentValue = 0.4
        model.skinParameters = skins
        
        var shapes: [BeautyParameterModel] = shapes()
        shapes = setDefault(shapes: shapes)
        shapes[BeautyShape.cheekThinning.rawValue].currentValue = 0.3
        shapes[BeautyShape.nose.rawValue].currentValue = 0.5
        shapes[BeautyShape.eyeEnlarging.rawValue].currentValue = 0.25
        model.shapeParameters = shapes
        
        model.index = 2
        
        return model
    }
    
    private func beautyStyle3() -> BeautyStyleModel {
        let model = BeautyStyleModel()
        model.name = "style3"
        model.filter = BeautyFilterModel(name: "origin", value: 0.4, index: -1)
        
        var skins: [BeautyParameterModel] = skins()
        skins = setDefault(shapes: skins)
        skins[BeautySkin.colorLevel.rawValue].currentValue = 0.6
        skins[BeautySkin.redLevel.rawValue].currentValue = 0.1
        skins[BeautySkin.blurLevel.rawValue].currentValue = 1.8
        model.skinParameters = skins
        
        var shapes: [BeautyParameterModel] = shapes()
        shapes = setDefault(shapes: shapes)
        shapes[BeautyShape.cheekThinning.rawValue].currentValue = 0.3
        shapes[BeautyShape.cheekShort.rawValue].currentValue = 0.15
        shapes[BeautyShape.nose.rawValue].currentValue = 0.3
        shapes[BeautyShape.eyeEnlarging.rawValue].currentValue = 0.65
        model.shapeParameters = shapes
        
        model.index = 3
        
        return model
    }
    
    private func beautyStyle4() -> BeautyStyleModel {
        let model = BeautyStyleModel()
        model.name = "style4"
        model.filter = BeautyFilterModel(name: "origin", value: 0.4, index: -1)
        
        var skins: [BeautyParameterModel] = skins()
        skins = setDefault(shapes: skins)
        skins[BeautySkin.colorLevel.rawValue].currentValue = 0.25
        skins[BeautySkin.blurLevel.rawValue].currentValue = 3.0
        model.skinParameters = skins
        
        var shapes: [BeautyParameterModel] = shapes()
        shapes = setDefault(shapes: shapes)
        model.shapeParameters = shapes
        
        model.index = 4
        
        return model
    }
    
    private func beautyStyle5() -> BeautyStyleModel {
        let model = BeautyStyleModel()
        model.name = "style5"
        model.filter = BeautyFilterModel(name: "fennen1", value: 0.4, index: -1)
        
        var skins: [BeautyParameterModel] = skins()
        skins = setDefault(shapes: skins)
        skins[BeautySkin.colorLevel.rawValue].currentValue = 0.7
        skins[BeautySkin.blurLevel.rawValue].currentValue = 3
        model.skinParameters = skins
        
        var shapes: [BeautyParameterModel] = shapes()
        shapes = setDefault(shapes: shapes)
        shapes[BeautyShape.cheekThinning.rawValue].currentValue = 0.35
        shapes[BeautyShape.eyeEnlarging.rawValue].currentValue = 0.65
        model.shapeParameters = shapes
        
        model.index = 5
        
        return model
    }
    
    private func beautyStyle6() -> BeautyStyleModel {
        let model = BeautyStyleModel()
        model.name = "style6"
        model.filter = BeautyFilterModel(name: "fennen1", value: 0.4, index: -1)
        
        var skins: [BeautyParameterModel] = skins()
        skins = setDefault(skins: skins)
        skins[BeautySkin.colorLevel.rawValue].currentValue = 0.5
        skins[BeautySkin.blurLevel.rawValue].currentValue = 3
        model.skinParameters = skins
        
        var shapes: [BeautyParameterModel] = shapes()
        shapes = setDefault(shapes: shapes)
        model.shapeParameters = shapes;
        
        model.index = 6
        
        return model
    }
    
    private func beautyStyle7() -> BeautyStyleModel {
        let model = BeautyStyleModel()
        model.name = "style7"
        model.filter = BeautyFilterModel(name: "ziran5", value: 0.55, index: -1)
        
        var skins: [BeautyParameterModel] = skins()
        skins = setDefault(skins: skins)
        skins[BeautySkin.colorLevel.rawValue].currentValue = 0.2
        skins[BeautySkin.redLevel.rawValue].currentValue = 0.65
        skins[BeautySkin.blurLevel.rawValue].currentValue = 3.3
        model.skinParameters = skins
        
        var shapes: [BeautyParameterModel] = shapes()
        shapes = setDefault(shapes: shapes)
        shapes[BeautyShape.cheekThinning.rawValue].currentValue = 0.1
        shapes[BeautyShape.cheekShort.rawValue].currentValue = 0.05
        model.shapeParameters = shapes
        
        model.index = 7
        
        return model
    }
    
}

extension BeautyViewModel {
    
    //MARK: Override FURenderKitDelegate
    
    override func renderKitWillRender(from renderInput: FURenderInput!) {
        super.renderKitWillRender(from: renderInput)
        updateBeautyBlurEffect()
    }

    override func renderKitDidRender(to renderOutput: FURenderOutput!) {
        super.renderKitDidRender(to: renderOutput)
    }
    
}
