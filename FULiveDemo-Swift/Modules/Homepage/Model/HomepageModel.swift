//
//  HomepageModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/11.
//

import HandyJSON

enum ModuleCategory: Int {
    case faceEffects = 0, bodyEffects, contentService
    var title: String {
        switch self {
            case .faceEffects:
                return "人脸特效"
            case .bodyEffects:
                return "人体特效"
            case .contentService:
                return "内容服务"
        }
    }
}

enum ModuleType: Int {
    case beauty = 0
}

struct HomepageModel: HandyJSON {
    var type: Int?
    var name: String?
    var icon: String?
    var enabled: Bool?
    // 模块对比代码
    var moduleCode: Int?
    var modules: [Int]?
    var items: [Any]?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< type <-- "itemType"
        mapper <<< name <-- "itemName"
        mapper <<< moduleCode <-- "conpareCode"
    }
}
