//
//  BaseViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/12.
//

import UIKit
import FURenderKit

enum CapturePreset: Int {
    case preset480x640 = 0, preset720x1280, preset1080x1920
    var title: String {
        switch self {
        case .preset480x640:
            return "480x640"
        case .preset720x1280:
            return "720x1280"
        case .preset1080x1920:
            return "1080x1920"
        }
    }
}

typealias BuglyInformationClosure = (_ informationString: String) -> Void
typealias FaceTraceClosure = (_ tracked: Bool) -> Void

class BaseViewModel: NSObject {
    
    var buglyInformationCallBack: BuglyInformationClosure?
    var faceTraceCallBack: FaceTraceClosure?
    
    /// 是否需要渲染
    var isRendering: Bool = true
    
    /// 是否检测到人脸
    var faceTrace: Bool {
        return FUAIKit.share().trackedFacesCount > 0
    }
    
    /// 是否检测到人体
    var bodyTrace: Bool {
        return FUAIKit.aiHumanProcessorNums() > 0
    }
    
    /// 是否前置摄像头
    var isFrontCamera: Bool {
        return FURenderKit.share().captureCamera.isFrontCamera
    }
    
    /// 支持的分辨率
    var supportsPresets: [CapturePreset] {
        return [.preset480x640, .preset720x1280, .preset1080x1920]
    }
    
    /// 选中的分辨率
    var selectedPreset: CapturePreset  = .preset720x1280
    
    /// 是否支持导入图片和视频
    var isSupportMedia: Bool {
        return true
    }
    
    /// 输入图像宽度
    var inputBufferWidth: size_t!
    
    /// 输入图像高度
    var inputBufferHeight: size_t!
    
    /// 人脸中心点
    var faceCenter: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    /// 计算帧率相关变量
    private var startTime: CFAbsoluteTime!, rate: Int = 0, lastCalculateTime: CFAbsoluteTime = 0, currentCalculateTime: TimeInterval = 0
    
    func loadItem() {}
    
    func releaseItem() {}
    
    final func startCamera(view: FUGLDisplayView) {
        FURenderKit.share().startInternalCamera()
        FURenderKit.share().glDisplayView = view
        FURenderKit.share().delegate = self
        FURenderKit.share().captureCamera.dataSource = self
    }
    
    final func stopCamera() {
        FURenderKit.share().stopInternalCamera()
        FURenderKit.share().glDisplayView = nil
    }
    
    final func resetCameraSettings() {
        if setCapturePreset(preset: .preset720x1280) {
            FURenderKit.share().internalCameraSetting.sessionPreset = .hd1280x720
        }
        FURenderKit.share().internalCameraSetting.format = Int32(kCVPixelFormatType_32BGRA)
        if let camera = FURenderKit.share().captureCamera {
            camera.changeInputDeviceisFront(true)
            FURenderKit.share().internalCameraSetting.position = .front
        }
    }
    
    /// 添加麦克风输入（FURenderKit内部默认不开启麦克风输入）
    final func addMicrophoneInput() {
        FURenderKit.share().captureCamera.addAudio()
    }

    /// 切换摄像头
    final func switchCamera() {
        if let camera = FURenderKit.share().captureCamera {
            camera.changeInputDeviceisFront(!camera.isFrontCamera)
            if camera.isFrontCamera {
                FURenderKit.share().internalCameraSetting.position = .front
            } else {
                FURenderKit.share().internalCameraSetting.position = .back
            }
            resetTrackedResult()
        }
    }
    
    /// 切换视频格式
    final func switchFormat() {
        let format = FURenderKit.share().internalCameraSetting.format == kCVPixelFormatType_32BGRA ? kCVPixelFormatType_420YpCbCr8BiPlanarFullRange : kCVPixelFormatType_32BGRA
        FURenderKit.share().internalCameraSetting.format = Int32(format)
    }
    
    /// 重置检测结果
    final func resetTrackedResult() {
        FUAIKit.resetTrackedResult()
    }
    
    /// 设置人脸检测模式
    final func setFaceProcessorDetectMode(mode: FUFaceProcessorDetectMode) {
        FUAIKit.share().faceProcessorDetectMode = mode
    }
    
    /// 设置最大人脸数量
    final func setMaxFaces(faceNumber: Int) {
        FUAIKit.share().maxTrackFaces = Int32(faceNumber)
    }
    
    /// 设置最大人体数量
    final func setMaxBodies(bodyNumber: Int) {
        FUAIKit.share().maxTrackBodies = Int32(bodyNumber)
    }
    
    final func setFocusMode(mode: FUCaptureCameraFocusModel) {
        if let camera = FURenderKit.share().captureCamera {
            camera.cameraChangeModle(mode)
        }
    }
    
    final func setFocusPoint(point: CGPoint) {
        if let camera = FURenderKit.share().captureCamera {
            camera.focus(with: .continuousAutoFocus, exposeWith: .continuousAutoExposure, atDevicePoint: point, monitorSubjectAreaChange: true)
        }
    }
    
    final func setExposureValue(value: Float) {
        if let camera = FURenderKit.share().captureCamera {
            camera.setExposureValue(value)
        }
    }
    
    final func setCapturePreset(preset: CapturePreset) -> Bool {
        var result = false
        if let camera = FURenderKit.share().captureCamera {
            switch preset {
            case .preset480x640:
                result = camera.changeSessionPreset(.vga640x480)
                if result {
                    FURenderKit.share().internalCameraSetting.sessionPreset = .vga640x480
                }
            case .preset720x1280:
                result = camera.changeSessionPreset(.hd1280x720)
                if result {
                    FURenderKit.share().internalCameraSetting.sessionPreset = .hd1280x720
                }
            case .preset1080x1920:
                result = camera.changeSessionPreset(.hd1920x1080)
                if result {
                    FURenderKit.share().internalCameraSetting.sessionPreset = .hd1920x1080
                }
            }
        }
        if result == true {
            selectedPreset = preset
        }
        return result
    }
    /// 拍照
    final func capturePhoto() {
        if let image = FURenderKit.captureImage() {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(savedPhotosAlbum(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    /// 开始录制视频
    final func startRecordingVideo() {
        let videoName = String(format: "%@.mp4", CurrentDateString())
        let videoPathURL = URL(string: NSTemporaryDirectory())?.appendingPathComponent(videoName)
        FURenderKit.startRecordVideo(withFilePath: videoPathURL?.absoluteString)
    }
    
    /// 结束录制视频
    final func finishRecordingVideo() {
        FURenderKit.stopRecordVideoComplention { filePath in
            DispatchQueue.main.async {
                UISaveVideoAtPathToSavedPhotosAlbum(filePath!, self, #selector(self.savedVideo(video:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    /// 保存图片到相册
    @objc private func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: AnyObject) {
        if error != nil {
            ProgressHUD.showError(message: NSLocalizedString("保存图片失败", comment: ""))
        } else {
            ProgressHUD.showSuccess(message: NSLocalizedString("图片已保存到相册", comment: ""))
        }
    }
    
    @objc private func savedVideo(video: String,didFinishSavingWithError error: Error?, contextInfo: AnyObject) {
        if error != nil {
            ProgressHUD.showError(message: NSLocalizedString("保存视频失败", comment: ""))
        } else {
            ProgressHUD.showSuccess(message: NSLocalizedString("视频已保存到相册", comment: ""))
        }
    }
    
    /// 保存人脸中心点
    private func saveFaceCenterPoint() {
        let faceEnabled = faceTrace
        var center: CGPoint = CGPoint(x: 0.5, y: 0.5)
        if faceEnabled {
            if let camera = FURenderKit.share().captureCamera {
                let faceCenter = getFaceCenter()
                // 考虑前置镜像问题
                if camera.isFrontCamera {
                    center = CGPoint(x: faceCenter.y, y: faceCenter.x)
                } else {
                    center = CGPoint(x: faceCenter.y, y: 1 - faceCenter.x)
                }
            }
        }
        faceCenter = center
    }
    
    /// 获取人脸中心点
    private func getFaceCenter() -> CGPoint {
        // 获取人脸信息
        let rect: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: 4)
        FUAIKit.getFaceInfo(0, name: "face_rect", pret: rect, number: 4)
        let minX: CGFloat = CGFloat(rect[0])
        let minY: CGFloat = CGFloat(rect[1])
        let maxX: CGFloat = CGFloat(rect[2])
        let maxY: CGFloat = CGFloat(rect[3])
        // 计算中心点的坐标
        var centerX = (minX + maxX) * 0.5
        var centerY = (minY + maxY) * 0.5
        // 转换坐标
        centerX = centerX / CGFloat(inputBufferWidth)
        centerY = centerY / CGFloat(inputBufferHeight)
        return CGPoint(x: centerX, y: centerY)
    }
}

//MARK: FUCaptureCameraDataSource & FURenderKitDelegate

extension BaseViewModel: FUCaptureCameraDataSource, FURenderKitDelegate {
    
    func fuCaptureFaceCenter(inImage camera: FUCaptureCamera!) -> CGPoint {
        return faceCenter
    }
    
    func renderKitShouldDoRender() -> Bool {
        return isRendering
    }
    
    func renderKitWillRender(from renderInput: FURenderInput!) {
        inputBufferWidth = CVPixelBufferGetWidth(renderInput.pixelBuffer)
        inputBufferHeight = CVPixelBufferGetHeight(renderInput.pixelBuffer)
        
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func renderKitDidRender(to renderOutput: FURenderOutput!) {
        let endTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        // 加一帧占用时间
        currentCalculateTime += (endTime - startTime)
        // 加帧数
        rate += 1
        if (endTime - lastCalculateTime >= 1) {
            // 一秒钟计算一次
            let width = CVPixelBufferGetWidth(renderOutput.pixelBuffer)
            let height = CVPixelBufferGetHeight(renderOutput.pixelBuffer)
            let bugString = String(format: "resolution:\n%dx%d\nfps: %d\nrender time:\n%.0fms", width, height, rate, currentCalculateTime*1000/Double(rate));
            // bugly信息回调
            if let callBack = buglyInformationCallBack {
                callBack(bugString)
            }
            // 恢复计算数据
            lastCalculateTime = endTime
            currentCalculateTime = 0
            rate = 0
        }
        
        // 更新人脸中心点
        saveFaceCenterPoint()
        
        // 人脸检测回调
        if let callBack = faceTraceCallBack {
            callBack(faceTrace)
        }
    }
}
