//
//  PopupMenu.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/22.
//

import UIKit

@objc protocol PopupMenuDelegate {
    func popMenu(didSelectAtIndex index: Int)
    @objc optional func popMenuDidClickSelectingMedia()
}

private let keyWindow = UIApplication.shared.keyWindow

class PopupMenu: UIView {
    
    var selectedIndex: Int!
    var isSupportedMedia: Bool!
    var dataSource: [String]?
    var arrowPoint: CGPoint?
    
    weak var delegate: PopupMenuDelegate?
    
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: keyWindow!.bounds)
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    class func show(reliablyView: UIView, frame: CGRect, selectedIndex: Int = 0, isSupportedMedia: Bool = true, dataSource: [String]?, delegate: PopupMenuDelegate?) {
        // 获取reliablyView在keyWindow的位置
        let rectInKeyWindow = reliablyView.convert(reliablyView.bounds, to: keyWindow)
        // 计算箭头点坐标
        let arrowPoint = CGPoint(x: rectInKeyWindow.origin.x + rectInKeyWindow.width / 2.0, y: rectInKeyWindow.origin.y + rectInKeyWindow.height)
        let menu = PopupMenu(frame: frame, selectedIndex: selectedIndex, isSupportedMedia: isSupportedMedia, dataSource: dataSource)
        menu.arrowPoint = arrowPoint
        menu.delegate = delegate
        menu.layer.anchorPoint = CGPoint(x: (arrowPoint.x - frame.origin.x) / frame.size.width, y: 0)
        menu.layer.frame = frame
        menu.show()
    }
    
    init(frame: CGRect, selectedIndex: Int = 0, isSupportedMedia: Bool = true, dataSource: [String]?) {
        self.selectedIndex = selectedIndex
        self.isSupportedMedia = isSupportedMedia
        self.dataSource = dataSource
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        let contentView = UIView(frame: CGRect(x: 0, y: 10, width: frame.size.width, height: frame.size.height - 10))
        contentView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        contentView.layer.cornerRadius = 5.0
        addSubview(contentView)
        
        if self.dataSource == nil || self.dataSource?.count == 0 {
            self.dataSource = ["480×640", "720×1280", "1080×1920"]
        }
        let segment = UISegmentedControl(items: self.dataSource)
        segment.frame = CGRect(x: 25, y: 28, width: frame.size.width - 50, height: 32)
        segment.selectedSegmentIndex = selectedIndex
        segment.tintColor = .white
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal) // 未选中状态颜色
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segment.addTarget(self, action: #selector(segmentValueChanged(sender:)), for: .valueChanged)
        segment.layer.cornerRadius = 4
        segment.layer.borderWidth = 1;
        segment.layer.borderColor = UIColor.white.cgColor
        addSubview(segment)
        
        
        
        if isSupportedMedia {
            let line = UIView(frame: CGRect(x: 25, y: 80, width: frame.size.width - 50, height: 0.5))
            line.layer.backgroundColor = UIColor(redValue: 229, greenValue: 229, blueValue: 229).cgColor
            addSubview(line)
            
            let mediaButton = UIButton(frame: CGRect(x: 25, y: 81, width: frame.size.width - 50, height: 50))
            mediaButton.setImage(UIImage(named: "demo_icon_add_to"), for: .normal)
            mediaButton.setTitle(NSLocalizedString("载入图片或视频", comment: ""), for: .normal)
            mediaButton.titleLabel?.font = .systemFont(ofSize: 13)
            mediaButton.titleLabel?.textAlignment = .left
            mediaButton.setTitleColor(.white, for: .normal)
            mediaButton.addTarget(self, action: #selector(mediaAction(sender:)), for: .touchUpInside)
            
            let frameWidth = mediaButton.frame.size.width
            if let imageFrameWidth = mediaButton.imageView?.frame.size.width, let titleFrameWidth = mediaButton.titleLabel?.frame.size.width {
                mediaButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: frameWidth - imageFrameWidth, bottom: 0, right: 0)
                mediaButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -frameWidth - imageFrameWidth + titleFrameWidth, bottom: 0, right: 0)
            }
            addSubview(mediaButton)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if let point = arrowPoint, let context = UIGraphicsGetCurrentContext() {
            // 画三角形
            context.beginPath()
            context.move(to: CGPoint(x: point.x - frame.origin.x, y: 0))
            context.addLine(to: CGPoint(x: point.x - frame.origin.x - 10, y: 10))
            context.addLine(to: CGPoint(x: point.x - frame.origin.x + 10, y: 10))
            context.closePath()
            UIColor(white: 0, alpha: 0.6).setFill()
            UIColor.clear.setStroke()
            context.drawPath(using: .fillStroke)
        }
    }
    
    @objc private func backgroundTap() {
        dismiss()
    }
    
    @objc private func segmentValueChanged(sender: UISegmentedControl) {
        if let delegate = delegate {
            delegate.popMenu(didSelectAtIndex: sender.selectedSegmentIndex)
        }
    }
    
    @objc private func mediaAction(sender: UIButton) {
        if let delegate = delegate {
            delegate.popMenuDidClickSelectingMedia?()
            dismiss()
        }
    }
    
    private func show() {
        keyWindow?.addSubview(backgroundView)
        keyWindow?.addSubview(self)
        self.layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
        UIView.animate(withDuration: 0.25) {
            self.layer.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
            self.alpha = 1
        } completion: { finished in
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.25) {
            self.layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
            self.alpha = 0
        } completion: { finished in
            self.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
        }
    }
    
}
