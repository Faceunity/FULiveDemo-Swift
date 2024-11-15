//
//  BaseViewController.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/12.
//

import FURenderKit
import UIKit

class BaseViewController<T: BaseViewModel>: UIViewController, HeaderFunctionViewDelegate, CaptureDelegate, PopupMenuDelegate {
    var functionTypes: [HeaderFunctionType] {
        return [.back, .switchFormat, .selectMedia, .bugly, .switchCamera]
    }
    
    lazy var renderView: FUGLDisplayView = {
        let displayView = FUGLDisplayView(frame: .zero)
        let tap = UITapGestureRecognizer(target: self, action: #selector(renderViewTapAction(sender:)))
        displayView.addGestureRecognizer(tap)
        return displayView
    }()
    
    lazy var headerFunctionView: HeaderFunctionView = {
        let view = HeaderFunctionView(frame: .zero, functionTypes: self.functionTypes)
        view.delegate = self
        return view
    }()
    
    lazy var buglyLabel: InsetsLabel = {
        let label = InsetsLabel(frame: .zero, insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.numberOfLines = 0
        label.backgroundColor = .darkGray
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.alpha = 0.74
        label.isHidden = true
        return label
    }()
    
    lazy var traceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17)
        label.text = NSLocalizedString("未检测到人脸", comment: "")
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var captureButton: CaptureButton = {
        let button = CaptureButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        button.delegate = self
        return button
    }()
    
    lazy var focusImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "camera_focus"))
        imageView.center = view.center
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var lightingView: LightingView = {
        let view = LightingView(frame: CGRect(x: 0, y: 0, width: 280, height: 40)) { [weak self] value in
            // 曝光度调节
            self?.operatedTime = CFAbsoluteTimeGetCurrent()
            self?.viewModel.setExposureValue(value: value)
            self?.hideFocusAndLightingView(after: 1.3)
        }
        view.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        view.isHidden = true
        return view
    }()
    
    var viewModel: T
    
    // MARK: Life cycle
    
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.buglyInformationCallBack = { [weak self] (information: String) in
            DispatchQueue.main.async {
                self?.buglyLabel.text = information
            }
        }
        
        self.viewModel.faceTraceCallBack = { [weak self] (tracked: Bool) in
            if self?.viewModel.aiTraceType == .None || tracked {
                DispatchQueue.main.async {
                    self?.traceLabel.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                    self?.traceLabel.isHidden = false
                    self?.traceLabel.text = self?.viewModel.aiTraceType == .Face ? "未检测到人脸" : self?.viewModel.aiTraceType == .Body ? "未检测到人体" : "未检测到手势"
                }
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 17 / 255.0, green: 18 / 255.0, blue: 38 / 255.0, alpha: 1.0)
        
        configureUI()
        
        viewModel.startCamera(view: renderView)
    }
    
    // MARK: UI
    
    private func configureUI() {
        view.backgroundColor = .black
        view.addSubview(renderView)
        renderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
        
        view.addSubview(headerFunctionView)
        headerFunctionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            } else {
                make.top.equalToSuperview().offset(30)
            }
            make.height.equalTo(44)
        }
        
        view.addSubview(focusImageView)
        
        view.addSubview(lightingView)
        lightingView.center = CGPoint(x: view.frame.width - 20, y: view.frame.size.height / 2.0 - 60)
        
        view.addSubview(buglyLabel)
        buglyLabel.snp.makeConstraints { make in
            make.top.equalTo(headerFunctionView.snp_bottom).offset(15)
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(90)
        }
        
        view.addSubview(traceLabel)
        traceLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(captureButton)
        captureButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 70, height: 70))
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
            } else {
                make.bottom.equalToSuperview().offset(-60)
            }
        }
    }
    
    /// 延迟隐藏对焦和曝光度控件
    /// - Parameter time: 延迟时间
    private func hideFocusAndLightingView(after time: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            let currentTime = CFAbsoluteTimeGetCurrent()
            if currentTime - self.operatedTime > 1.29 {
                self.lightingView.isHidden = true
                self.focusImageView.isHidden = true
            }
        }
    }
    
    /// 更新拍照按钮
    /// - Parameter constraint: 距离底部高度
    func updateCaptureButtonBottomConstraint(constraint: CGFloat) {
        updateCaptureButtonBottomConstraint(constraint: constraint, animated: true)
    }
    
    func updateCaptureButtonBottomConstraint(constraint: CGFloat, animated: Bool = true) {
        captureButton.snp.updateConstraints { make in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-constraint)
            } else {
                make.bottom.equalToSuperview().offset(-constraint)
            }
        }
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: Event response
    
    private var operatedTime: CFAbsoluteTime = 0
    
    /// 手动对焦
    @objc func renderViewTapAction(sender: UITapGestureRecognizer) {
        operatedTime = CFAbsoluteTimeGetCurrent()
        lightingView.isHidden = false
        focusImageView.isHidden = false
        viewModel.setFocusMode(mode: .changeless)
        var center = sender.location(in: renderView)
        focusImageView.center = center
        // 缩放动画
        focusImageView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.3) {
            self.focusImageView.transform = CGAffineTransform(scaleX: 0.67, y: 0.67)
        } completion: { _ in
            self.hideFocusAndLightingView(after: 1.1)
        }
        // 根据renderView的填充模式计算图像中心点
        var pictureCenter: CGPoint
        let scale = viewModel.inputBufferHeight / viewModel.inputBufferWidth
        let renderViewWidth = renderView.bounds.size.width, renderViewHeight = renderView.bounds.size.height
        if renderView.contentMode == .scaleAspectFill {
            // 短边填满(宽度按比例截取中间部分)
            let leading = (renderViewHeight / CGFloat(scale) - renderViewWidth) / 2.0
            let pictureWidth = renderViewWidth + leading * 2
            center.x += leading
            guard center.y > 0 else {
                return
            }
            pictureCenter = CGPoint(x: center.y / renderViewHeight, y: Manager.isFrontCamera ? center.x / pictureWidth : 1 - center.x / pictureWidth)
        } else if renderView.contentMode == .scaleAspectFit {
            // 长边填满(高度上下会留空白)
            let top = (renderViewHeight - renderViewWidth * CGFloat(scale)) / 2.0
            let pictureHeight = renderViewHeight - top * 2
            center.y -= top
            guard center.y > 0 else {
                return
            }
            pictureCenter = CGPoint(x: center.y / pictureHeight, y: Manager.isFrontCamera ? center.x / renderViewWidth : 1 - center.x / renderViewWidth)
        } else {
            // 拉伸填满
            pictureCenter = CGPoint(x: center.y / renderViewHeight, y: Manager.isFrontCamera ? center.x / renderViewWidth : 1 - center.x / renderViewWidth)
        }
        viewModel.setFocusPoint(point: pictureCenter)
    }
    
    // MARK: HeaderFunctionViewDelegate
    
    func headerFunctionView(view: HeaderFunctionView, didSelectFunction functionType: HeaderFunctionType) {
        switch functionType {
        case .back:
            viewModel.stopCamera()
            viewModel.resetCameraSettings()
            navigationController?.popViewController(animated: true)
        case .switchFormat:
            viewModel.switchFormat()
        case .selectMedia:
            // 当前选中的索引
            let presetIndex: Int! = viewModel.supportsPresets.firstIndex(of: viewModel.selectedPreset)
            var dataSource: [String] = []
            for preset in viewModel.supportsPresets {
                dataSource.append(preset.title)
            }
            PopupMenu.show(reliablyView: view.selectMediaButton, frame: CGRect(x: 17, y: view.frame.maxY + 1, width: 340, height: viewModel.isSupportMedia ? 132 : 80), selectedIndex: presetIndex, isSupportedMedia: viewModel.isSupportMedia, dataSource: dataSource, delegate: self)
        case .bugly:
            buglyLabel.isHidden = !buglyLabel.isHidden
        case .switchCamera:
            viewModel.switchCamera()
        default: break
        }
    }
    
    // MARK: CaptureDelegate
    
    func captureDidTakePhoto() {
        viewModel.capturePhoto()
    }
    
    func captureDidStartRecording() {
        viewModel.startRecordingVideo()
    }
    
    func captureDidFinishRecording() {
        viewModel.finishRecordingVideo()
    }
    
    // MARK: PopMenuDelegate
    
    func popMenu(didSelectAtIndex index: Int) {
        guard index >= 0 && index < viewModel.supportsPresets.count else {
            return
        }
        let result = viewModel.setCapturePreset(preset: viewModel.supportsPresets[index])
        if !result {
            ProgressHUD.showError(message: NSLocalizedString("设备不支持该分辨率", comment: ""))
        }
    }
    
    func popMenuDidClickSelectingMedia() {}
}
