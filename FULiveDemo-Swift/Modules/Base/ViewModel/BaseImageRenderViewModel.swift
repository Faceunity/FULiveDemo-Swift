//
//  BaseMediaRenderingViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/21.
//

import FURenderKit
import UIKit

protocol ImageRenderViewModelDelegate: AnyObject {
    func imageRenderDidOutput(pixelBuffer: CVPixelBuffer)
}

class BaseImageRenderViewModel: NSObject {
    private var displayLink: CADisplayLink?

    private lazy var renderOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private let renderImage: UIImage

    /// 是否需要渲染
    var isRendering: Bool = true

    /// 检测类型
    var traceType: AITraceType {
        return .Face
    }

    var faceTraceCallBack: FaceTraceClosure?

    var captureImageHandler: ((UIImage) -> Void)?

    // 设置人脸检测模式
    var aiModelType: AIModelType {
        didSet {
            switch aiModelType {
            case .Face:
                FUAIKit.share().faceProcessorDetectMode = FUFaceProcessorDetectModeImage
            case .Hand: break
            case .body:
                FUAIKit.share().faceProcessorDetectMode = FUFaceProcessorDetectModeVideo
            case .None: break
            }
        }
    }

    weak var delegate: ImageRenderViewModelDelegate?

    init(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 1) {
            self.renderImage = UIImage(data: data)!
        } else {
            self.renderImage = image
        }
        // 设置人脸检测模式
        self.aiModelType = .Face
        super.init()
    }

    func start() {
        FUAIKit.resetTrackedResult()
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction))
            displayLink?.add(to: .current, forMode: .common)
            if #available(iOS 10.0, *) {
                displayLink?.preferredFramesPerSecond = 10
            } else {
                displayLink?.frameInterval = 10
            }
        }
    }

    func stop() {
        displayLink?.isPaused = true
        displayLink?.invalidate()
        displayLink = nil
        renderOperationQueue.cancelAllOperations()
    }

    @objc private func displayLinkAction() {
        Manager.shared.updateBeautyBlurEffect()
        renderOperationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            autoreleasepool {
                guard let buffer = FUImageHelper.pixelBuffer(from: self.renderImage) else { return }

                let pixelBuffer = (buffer as! CVPixelBuffer)

                if self.isRendering {
                    let input = FURenderInput()
                    input.renderConfig.imageOrientation = self.convertImageOrientation(self.renderImage.imageOrientation)
                    input.pixelBuffer = pixelBuffer

                    let output = FURenderKit.share().render(with: input)
                    if output.pixelBuffer != nil {
                        self.processOutputResult(output.pixelBuffer)
                    }

                } else {
                    // 原图
                    self.processOutputResult(pixelBuffer)
                }
            }

            // 人脸检测回调
            if let callBack = faceTraceCallBack {
                if traceType == .Face {
                    callBack(Manager.faceTrace)
                } else if traceType == .Hand {
                    callBack(Manager.handTrace)
                } else if traceType == .Body {
                    callBack(Manager.bodyTrace)
                }
            }
        }
    }

    private func processOutputResult(_ pixelBuffer: CVPixelBuffer?) {
        guard let pixelBuffer = pixelBuffer else { return }

        delegate?.imageRenderDidOutput(pixelBuffer: pixelBuffer)

        if let handler = captureImageHandler {
            if let captureImage = FUImageHelper.image(from: pixelBuffer) {
                handler(captureImage)
                captureImageHandler = nil
            }
        }
    }

    private func convertImageOrientation(_ orientation: UIImage.Orientation) -> FUImageOrientation {
        switch orientation {
        case .up, .upMirrored:
            return FUImageOrientationUP
        case .left, .leftMirrored:
            return FUImageOrientationRight
        case .down, .downMirrored:
            return FUImageOrientationDown
        case .right, .rightMirrored:
            return FUImageOrientationLeft
        @unknown default:
            return FUImageOrientationUP
        }
    }
}
