//
//  HomepageModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/11.
//

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

struct HomepageModel: Codable {
    var type: Int?
    var name: String?
    var icon: String?
    var enabled: Bool?
    // 模块对比代码
    var moduleCode: Int?
    var modules: [Int]?

    enum CodingKeys: String, CodingKey {
        case type = "itemType"
        case name = "itemName"
        case icon
        case enabled
        case moduleCode = "conpareCode"
        case modules
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(Int.self, forKey: .type)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled)
        moduleCode = try container.decodeIfPresent(Int.self, forKey: .moduleCode)
        modules = try container.decodeIfPresent([Int].self, forKey: .modules)
    }
}
