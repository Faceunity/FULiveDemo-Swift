//
//  StickerViewManager.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/5.
//

import UIKit

class StickerViewManager: NSObject {
    private static var shared: StickerViewManager?
    static func sharedManager() -> StickerViewManager {
        if shared == nil {
            shared = StickerViewManager()
        }
        return shared!
    }

    private weak var targetView: UIView?
    lazy var stickerView: StickerView = {
        let view = StickerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width, height: 80))
        return view
    }()

    func addToTargetView(view: UIView) {
        targetView = view
        stickerView.removeFromSuperview()
        targetView?.addSubview(stickerView)
        stickerView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }

    static func destroy() {
        shared?.stickerView.onViewWillDisAppear()
        shared = nil
    }
}
