//
//  AutoDismissToast.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/5.
//

import UIKit

class AutoDismissToast: NSObject {
    // MARK: - Configuration

    struct Configuration {
        var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
        var textColor: UIColor = .white
        var fontSize: CGFloat = 15
        var cornerRadius: CGFloat = 8
        var horizontalPadding: CGFloat = 30
        var verticalOffset: CGFloat = 0
        var contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
        
    // MARK: - Properties

    private var config = Configuration()
    private var timeoutTimer: Timer?
    private var isShowing = false
        
    // MARK: - Singleton

    static let shared = AutoDismissToast()
    override private init() {
        super.init()
        // 初始化时设置默认样式
    }
        
    private lazy var toastView: UIView = {
        let view = UIView()
        view.backgroundColor = config.backgroundColor
        view.layer.cornerRadius = config.cornerRadius
        view.clipsToBounds = true
        view.alpha = 0
        return view
    }()
        
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: config.fontSize, weight: .medium)
        label.textColor = config.textColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
        
    // MARK: - Public Methods

    static func show(_ message: String, duration: TimeInterval = 1.5, config: Configuration? = nil) {
        DispatchQueue.main.async {
            shared.showToast(message, duration: duration, config: config)
        }
    }
    
    static func showType1(_ message: String) {
        AutoDismissToast.show(message, config: AutoDismissToast.Configuration(backgroundColor: .clear, fontSize: 26, verticalOffset: 30))
    }
        
    // MARK: - Private Methods
        
    private func showToast(_ message: String, duration: TimeInterval, config: Configuration? = nil) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        // 更新样式，逐个字段判断
        toastView.backgroundColor = config?.backgroundColor ?? self.config.backgroundColor
        messageLabel.textColor = config?.textColor ?? self.config.textColor
        messageLabel.font = .systemFont(ofSize: config?.fontSize ?? self.config.fontSize, weight: .bold)
        toastView.layer.cornerRadius = config?.cornerRadius ?? self.config.cornerRadius
        
        if isShowing {
            toastView.removeFromSuperview()
        }
        
        timeoutTimer?.invalidate()
        messageLabel.text = message
        
        keyWindow.addSubview(toastView)
        toastView.addSubview(messageLabel)
        
        toastView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(config?.verticalOffset ?? self.config.verticalOffset)
            make.left.greaterThanOrEqualToSuperview().offset(config?.horizontalPadding ?? self.config.horizontalPadding)
            make.right.lessThanOrEqualToSuperview().offset(-(config?.horizontalPadding ?? self.config.horizontalPadding))
        }
        
        messageLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(config?.contentEdgeInsets.top ?? self.config.contentEdgeInsets.top)
            make.bottom.equalToSuperview().offset(-(config?.contentEdgeInsets.bottom ?? self.config.contentEdgeInsets.bottom))
            make.left.equalToSuperview().offset(config?.contentEdgeInsets.left ?? self.config.contentEdgeInsets.left)
            make.right.equalToSuperview().offset(-(config?.contentEdgeInsets.right ?? self.config.contentEdgeInsets.right))
        }
        
        isShowing = true
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.toastView.alpha = 1
        }
        
        timeoutTimer = Timer.scheduledTimer(timeInterval: duration,
                                            target: self,
                                            selector: #selector(hideToastAction),
                                            userInfo: nil,
                                            repeats: false)
    }
        
    @objc private func hideToastAction() {
        hideToast()
    }
        
    private func hideToast() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.toastView.alpha = 0
        }, completion: { [weak self] _ in
            self?.toastView.removeFromSuperview()
            self?.isShowing = false
            self?.timeoutTimer = nil
        })
    }
        
    deinit {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
}
