//
//  BeautyEnums.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/13.
//

import Foundation

/// 美颜类别
/// 美肤、美型、滤镜、风格推荐
@objc enum BeautyCategory: Int {
    case skin = 0, shape, filter , preset, none
    var name: String {
        switch self {
        case .skin: return "美肤"
        case .shape: return "美型"
        case .filter: return "滤镜"
        case .preset: return "风格推荐"
        default: return ""
        }
    }
}

enum BeautySkin: Int {
    case blurLevel = 0, colorLevel, redLevel, sharpen, eyeBright, toothWhiten, removePouchStrength, removeNasolabialFoldsStrength
    var ratio: Float {
        switch self {
        case .blurLevel:
            return 6.0
        default:
            return 1.0
        }
    }
    var name: String {
        switch self {
        case .blurLevel: return "磨皮"
        case .colorLevel: return "美白"
        case .redLevel: return "红润"
        case .sharpen: return "锐化"
        case .eyeBright: return "亮眼"
        case .toothWhiten: return "美牙"
        case .removePouchStrength: return "去黑眼圈"
        case .removeNasolabialFoldsStrength: return "去法令纹"
        }
    }
    var defaultValue: Double {
        switch self {
        case .blurLevel: return 4.2
        case .colorLevel: return 0.3
        case .redLevel: return 0.3
        case .sharpen: return 0.2
        case .eyeBright: return 0.0
        case .toothWhiten: return 0.0
        case .removePouchStrength: return 0.0
        case .removeNasolabialFoldsStrength: return 0.0
        }
    }
    
    var defaultValueInMiddle: Bool {
        return false
    }
}

enum BeautyShape: Int {
    case cheekThinning = 0, cheekV, cheekNarrow, cheekShort, cheekSmall, cheekBones, lowerJaw, eyeEnlarging, eyeCycle, chin, forehead, nose, mouth, canthus, eyeSpace, eyeRotate, longNose, philtrum, smile
    var ratio: Float {
        return 1.0
    }
    var name: String {
        switch self {
        case .cheekThinning: return "瘦脸"
        case .cheekV: return "v脸"
        case .cheekNarrow: return "窄脸"
        case .cheekShort: return "短脸"
        case .cheekSmall: return "小脸"
        case .cheekBones: return "瘦颧骨"
        case .lowerJaw: return "瘦下颌骨"
        case .eyeEnlarging: return "大眼"
        case .eyeCycle: return "圆眼"
        case .chin: return "下巴"
        case .forehead: return "额头"
        case .nose: return "瘦鼻"
        case .mouth: return "嘴型"
        case .canthus: return "开眼角"
        case .eyeSpace: return "眼距"
        case .eyeRotate: return "眼睛角度"
        case .longNose: return "长鼻"
        case .philtrum: return "缩人中"
        case .smile: return "微笑嘴角"
        }
    }
    var defaultValue: Double {
        switch self {
        case .cheekThinning: return 0.0
        case .cheekV: return 0.5
        case .cheekNarrow: return 0.0
        case .cheekShort: return 0.0
        case .cheekSmall: return 0.0
        case .cheekBones: return 0.0
        case .lowerJaw: return 0.0
        case .eyeEnlarging: return 0.4
        case .eyeCycle: return 0.0
        case .chin: return 0.3
        case .forehead: return 0.3
        case .nose: return 0.5
        case .mouth: return 0.4
        case .canthus: return 0.0
        case .eyeSpace: return 0.5
        case .eyeRotate: return 0.5
        case .longNose: return 0.5
        case .philtrum: return 0.5
        case .smile: return 0.0
        }
    }
    
    var defaultValueInMiddle: Bool {
        switch self {
        case .chin, .forehead, .mouth, .eyeSpace, .eyeRotate, .longNose, .philtrum:
            return true
        default:
            return false
        }
    }
}

