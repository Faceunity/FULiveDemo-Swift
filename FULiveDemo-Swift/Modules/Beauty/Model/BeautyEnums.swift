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
    case skin = 0, shape, filter, none
    var name: String {
        switch self {
        case .skin: return "美肤"
        case .shape: return "美型"
        case .filter: return "滤镜"
        default: return ""
        }
    }
}

enum BeautySkin: Int {
    case blurLevel = 0,
         colorLevel,
         redLevel,
         sharpen,
         faceThreed,
         eyeBright,
         toothWhiten,
         removePouchStrength,
         removeNasolabialFoldsStrength,
         antiAcneSpot,
         clarity

    var defaultValueInMiddle: Bool {
        return false
    }
}

enum BeautyShape: Int {
    case cheekThinning = 0,
         cheekV,
         cheekNarrow,
         cheekShort,
         cheekSmall,
         cheekbones,
         lowerJaw,
         eyeEnlarging,
         eyeCircle,
         chin,
         forehead,
         nose,
         mouth,
         lipThick,
         eyeHeight,
         canthus,
         eyeLid,
         eyeSpace,
         eyeRotate,
         longNose,
         philtrum,
         smile,
         browHeight,
         browSpace,
         browThick
}
