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
        loadFaceAIModel()
    }
    
    func loadFaceAIModel() {
        if FUAIKit.loadedAIType(FUAITYPE_FACEPROCESSOR) {
            return
        }
        // 加载人脸AI模型
        var config = FUFaceAlgorithmConfigEnableAll
        if FURenderKit.devicePerformanceLevel().rawValue < 2 {
            config = FUFaceAlgorithmConfigDisableAll
        } else if FURenderKit.devicePerformanceLevel().rawValue < 3 {
            config = FUFaceAlgorithmConfig(rawValue:
                FUFaceAlgorithmConfigDisableSkinSeg.rawValue |
                    FUFaceAlgorithmConfigDisableARMeshV2.rawValue |
                    FUFaceAlgorithmConfigDisableRACE.rawValue)
        } else if FURenderKit.devicePerformanceLevel().rawValue < 4 {
            config = FUFaceAlgorithmConfigDisableSkinSeg
        }
        FUAIKit.setFaceAlgorithmConfig(config)
        
        let faceAIPath = Bundle.main.path(forResource: "ai_face_processor", ofType: "bundle")
        FUAIKit.loadAIMode(withAIType: FUAITYPE_FACEPROCESSOR, dataPath: faceAIPath!)
        
        // 设置人脸算法质量
        FUAIKit.share().faceProcessorFaceLandmarkQuality = FURenderKit.devicePerformanceLevel().rawValue > 2 ? FUFaceProcessorFaceLandmarkQualityHigh : FUFaceProcessorFaceLandmarkQualityMedium
        
        // 设置小脸检测是否打开
        FUAIKit.share().faceProcessorDetectSmallFace = FURenderKit.devicePerformanceLevel().rawValue > 2 ? true : false
        
        // 设置遮挡是否使用高精度模型（人脸算法质量为High时才生效）
        FUAIKit.share().faceProcessorSetFaceLandmarkHpOccu = false
    }
    
    // 卸载 faceAIModel
    func unloadFaceAIModel() {
        unloadAIModel(aiModelType: FUAITYPE_FACEPROCESSOR)
    }
    
    func loadHandAIModel() {
        if FUAIKit.loadedAIType(FUAITYPE_HANDGESTURE) {
            return
        }
        let faceAIPath = Bundle.main.path(forResource: "ai_hand_processor", ofType: "bundle")
        FUAIKit.loadAIMode(withAIType: FUAITYPE_HANDGESTURE, dataPath: faceAIPath!)
        // 设置未跟踪到手势时每次检测的间隔帧数为3
        FUAIKit.setHandDetectEveryFramesWhenNoHand(3)
    }
    
    // 卸载手势识别 AIModel
    func unloadHandAIModel() {
        unloadAIModel(aiModelType: FUAITYPE_HANDGESTURE)
    }
    
    /// 更新磨皮效果
    func updateBeautyBlurEffect() {
        let beauty = FURenderKit.share().beauty
        guard beauty != nil, beauty?.enable != false else { return }
        if FURenderKit.devicePerformanceLevel().rawValue >= 2 {
            // 高性能设备根据人脸置信度设置不同磨皮效果
            let score = FUAIKit.fuFaceProcessorGetConfidenceScore(0)
            if score > 0.95 {
                beauty!.blurType = 3
                beauty!.blurUseMask = true
            } else {
                beauty!.blurType = 2
                beauty!.blurUseMask = false
            }
        } else {
            // 低性能设备使用精细磨皮
            beauty!.blurType = 2
            beauty!.blurUseMask = false
        }
    }
    
    /// 是否检测到人脸
    static var faceTrace: Bool {
        return FUAIKit.share().trackedFacesCount > 0
    }
    
    /// 是否检测到人体
    static var bodyTrace: Bool {
        return FUAIKit.aiHumanProcessorNums() > 0
    }
    
    /// 是否检测到手势
    static var handTrace: Bool {
        return FUAIKit.aiHandDistinguishNums() > 0
    }
    
    /// 是否前置摄像头
    static var isFrontCamera: Bool {
        if let camera = FURenderKit.share().captureCamera {
            return camera.isFrontCamera
        }
        return true
    }
    
    private func unloadAIModel(aiModelType: FUAITYPE) {
        if FUAIKit.loadedAIType(aiModelType) {
            FUAIKit.unloadAIMode(forAIType: aiModelType)
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
