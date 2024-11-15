//
//  HeaderFunctionView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/12.
//

import UIKit

@objc enum HeaderFunctionType: Int {
    case back = 0, switchFormat, selectMedia, bugly, switchCamera
}

@objc protocol HeaderFunctionViewDelegate {
    func headerFunctionView(view: HeaderFunctionView, didSelectFunction functionType: HeaderFunctionType)
}

class HeaderFunctionView: UIView {
    private var functionTypes: [HeaderFunctionType] = []
    weak var delegate: HeaderFunctionViewDelegate?
    
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "header_back_home"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return backButton
    }()
    
    lazy var switchFormatSegment: UISegmentedControl = {
        let switchFormatSegment = UISegmentedControl(items: ["BGRA", "YUV"])
        switchFormatSegment.tintColor = UIColor.white
        switchFormatSegment.selectedSegmentIndex = 0
        switchFormatSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal) // 未选中状态颜色
        switchFormatSegment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        switchFormatSegment.addTarget(self, action: #selector(switchFormatAction), for: .valueChanged)
        switchFormatSegment.layer.cornerRadius = 4
        switchFormatSegment.layer.borderWidth = 1
        switchFormatSegment.layer.borderColor = UIColor.white.cgColor
        return switchFormatSegment
    }()
    
    lazy var selectMediaButton: UIButton = {
        let selectMediaButton = UIButton()
        selectMediaButton.setImage(UIImage(named: "header_more"), for: .normal)
        selectMediaButton.addTarget(self, action: #selector(selectMediaAction), for: .touchUpInside)
        return selectMediaButton
    }()
    
    lazy var buglyButton: UIButton = {
        let buglyButton = UIButton()
        buglyButton.setImage(UIImage(named: "header_bugly"), for: .normal)
        buglyButton.addTarget(self, action: #selector(buglyAction), for: .touchUpInside)
        return buglyButton
    }()
    
    lazy var switchCameraButton: UIButton = {
        let switchCameraButton = UIButton()
        switchCameraButton.setImage(UIImage(named: "header_switch_camera"), for: .normal)
        switchCameraButton.addTarget(self, action: #selector(switchCameraAction), for: .touchUpInside)
        return switchCameraButton
    }()
    
    init(frame: CGRect, functionTypes: [HeaderFunctionType]) {
        self.functionTypes = functionTypes
        super.init(frame: frame)
        
        addSubview(backButton)
        backButton.snp_makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self).offset(10)
            make.height.width.equalTo(44)
        }
        
        if functionTypes.contains(.switchFormat) {
            addSubview(switchFormatSegment)
            switchFormatSegment.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(backButton.snp_trailing).offset(11)
                make.size.equalTo(CGSize(width: 90, height: 24))
            }
        }
        
        // 从右向左依次添加按钮
        var lastView: UIView = self
        var lastOffset: CGFloat = -10
        
        if functionTypes.contains(.switchCamera) {
            addSubview(switchCameraButton)
            switchCameraButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(lastOffset)
                make.height.width.equalTo(44)
            }
            lastView = switchCameraButton
            lastOffset = -10
        }
        
        if functionTypes.contains(.bugly) {
            addSubview(buglyButton)
            buglyButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalTo(lastView === self ? lastView : lastView.snp_leading).offset(lastOffset)
                make.height.width.equalTo(44)
            }
            lastView = buglyButton
        }
        
        if functionTypes.contains(.selectMedia) {
            addSubview(selectMediaButton)
            selectMediaButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalTo(lastView === self ? lastView : lastView.snp_leading).offset(lastOffset)
                make.height.width.equalTo(44)
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: Event response
    
    @objc private func backAction() {
        if let delegate = delegate {
            delegate.headerFunctionView(view: self, didSelectFunction: .back)
        }
    }
    
    @objc private func switchFormatAction() {
        if let delegate = delegate {
            delegate.headerFunctionView(view: self, didSelectFunction: .switchFormat)
        }
    }
    
    @objc private func selectMediaAction() {
        if let delegate = delegate {
            delegate.headerFunctionView(view: self, didSelectFunction: .selectMedia)
        }
    }
    
    @objc private func buglyAction() {
        if let delegate = delegate {
            delegate.headerFunctionView(view: self, didSelectFunction: .bugly)
        }
    }
    
    @objc private func switchCameraAction() {
        // 防止暴力点击
        switchCameraButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.switchCameraButton.isEnabled = true
        }
        if let delegate = delegate {
            delegate.headerFunctionView(view: self, didSelectFunction: .switchCamera)
        }
    }
}
