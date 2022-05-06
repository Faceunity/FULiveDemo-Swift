//
//  Manager.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/11.
//

import Foundation
import FURenderKit
import FURenderKit.UIDevice_FURenderKit

class Manager {
    static let shared = Manager()
    
    func setupRenderKit() {
        let config = FUSetupConfig()
        let authData: UnsafeMutablePointer<CChar> = transform(&g_auth_package)
        let size = MemoryLayout.size(ofValue: g_auth_package)
        config.authPack = FUAuthPackMake(authData, Int32(size))
        FURenderKit.setup(with: config)
        FURenderKit.setLogLevel(FU_LOG_LEVEL_INFO)
        DispatchQueue.global().async {
            // 加载人脸AI模型
            let faceAIPath = Bundle.main.path(forResource: "ai_face_processor", ofType: "bundle")
            FUAIKit.loadAIMode(withAIType: FUAITYPE_FACEPROCESSOR, dataPath: faceAIPath!)
            
            // 加载手势AI模型
            let handAIPath = Bundle.main.path(forResource: "ai_hand_processor", ofType: "bundle")
            FUAIKit.loadAIMode(withAIType: FUAITYPE_HANDGESTURE, dataPath: handAIPath!)
            
            // 设置人脸算法质量
            FUAIKit.share().faceProcessorFaceLandmarkQuality = FURenderKit.devicePerformanceLevel() == .high ? FUFaceProcessorFaceLandmarkQualityHigh : FUFaceProcessorFaceLandmarkQualityMedium
            
            // 设置小脸检测是否打开
            FUAIKit.share().faceProcessorDetectSmallFace = FURenderKit.devicePerformanceLevel() == .high
        }
    }
    
    private func transform(_ data: UnsafeMutableRawPointer) -> UnsafeMutablePointer<CChar> {
        let dataPointer: UnsafeMutableRawPointer = data
        let opaque = OpaquePointer(dataPointer)
        print(opaque.debugDescription.count)
        let result = UnsafeMutablePointer<CChar>(opaque)
        return result
    }
}
