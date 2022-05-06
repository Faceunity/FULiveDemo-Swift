//
//  CaptureButton.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/21.
//

import UIKit

@objc protocol CaptureDelegate {
    func captureDidTakePhoto()
    func captureDidStartRecording()
    func captureDidFinishRecording()
}

class CaptureButton: UIView {
    
    private lazy var circleProgress: CircleProgressView = {
        let progressView = CircleProgressView(frame: CGRect(x: 1, y: 1, width: bounds.size.width - 2, height: bounds.height - 2))
        progressView.isUserInteractionEnabled = false
        return progressView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(frame: bounds)
        button.setImage(UIImage(named: "camera_btn_camera_normal"), for: .normal)
        return button
    }()
    
    private var timeCount = 0
    
    private var timer: Timer?
    
    weak var delegate: CaptureDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(button)
        addSubview(circleProgress)
        
        // 点击拍照
        button.addCommonAction(delay: 0.1) { [weak self] in
            if let delegate = self?.delegate {
                delegate.captureDidTakePhoto()
            }
        }
        
        // 长按录制视频
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(sender:)))
        longPress.minimumPressDuration = 0.3
        addGestureRecognizer(longPress)
       // longPress.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleProgress.frame = CGRect(x: 1, y: 1, width: bounds.size.width - 2, height: bounds.height - 2)
    }
    
    //MARK: Event response
    
    @objc private func longPressAction(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            timer?.fire()
            // 开始录制
            startRecording()
        } else if sender.state == .ended {
            stopRecording()
            invalidateTimer()
        }
    }
    
    @objc private func updateTime() {
        timeCount += 1
        circleProgress.percent += 0.01
        if timeCount > 100 {
            // 自动结束录制视频
            stopRecording()
            invalidateTimer()
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
        timeCount = 0
        circleProgress.percent = 0
    }
    
    private func startRecording() {
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
        if let delegate = delegate {
            delegate.captureDidStartRecording()
        }
    }
    
    private func stopRecording() {
        transform = .identity
        if let delegate = delegate {
            delegate.captureDidFinishRecording()
        }
    }
}

//MARK: UIGestureRecognizerDelegate

//extension CaptureButton: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//}

typealias ClickClosure = () -> Void

//MARK: 防止重复点击扩展
extension UIButton {
    private struct ButtonRuntimeKey {
        static let actionClosureKey = UnsafeRawPointer(bitPattern: "actionClosure".hashValue)
        static let delayTimeKey = UnsafeRawPointer(bitPattern: "delayTime".hashValue)
    }
    
    //MARK: Runtime关联属性
    private var actionClosure: ClickClosure? {
        set {
            objc_setAssociatedObject(self, UIButton.ButtonRuntimeKey.actionClosureKey!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, UIButton.ButtonRuntimeKey.actionClosureKey!) as? ClickClosure
        }
    }
    
    private var delayTime: TimeInterval {
        set {
            objc_setAssociatedObject(self, UIButton.ButtonRuntimeKey.delayTimeKey!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, UIButton.ButtonRuntimeKey.delayTimeKey!) as? TimeInterval ?? 0
        }
    }
    
    /// 添加点击时间扩展方法
    /// - Parameters:
    ///   - delay: 点击延迟时间
    ///   - actionClosure: 回调
    func addCommonAction(delay: TimeInterval = 0, actionClosure: @escaping ClickClosure) {
        addTarget(self, action: #selector(clickAction(sender:)), for: .touchUpInside)
        self.delayTime = delay
        self.actionClosure = actionClosure
    }
    
    @objc private func clickAction(sender: UIButton) {
        if let closure = actionClosure {
            closure()
            isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) { [weak self] in
                self?.isEnabled = true
            }
        }
        
    }
}
