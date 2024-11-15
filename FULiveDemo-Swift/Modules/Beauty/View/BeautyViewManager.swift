//
//  BeautyViewManager.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/7.
//

import UIKit

class BeautyViewManager: NSObject {
    private static var shared: BeautyViewManager?
    var viewModel: BeautyViewModel!

    static func sharedManager() -> BeautyViewManager {
        if shared == nil {
            shared = BeautyViewManager()
        }
        return shared!
    }

    private weak var targetView: UIView?
    lazy var beautyView: BeautyView = {
        let view = BeautyView(frame: CGRectMake(0, UIScreen.main.bounds.height-146, UIScreen.main.bounds.width, 146), viewModel: viewModel)
        return view
    }()

    func addToTargetView(view: UIView) {
        targetView = view
        beautyView.removeFromSuperview()
        targetView?.addSubview(beautyView)
        beautyView.snp.remakeConstraints { make in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(146)
        }
    }

    static func destroy() {
        shared?.beautyView.onViewWillDisappear()
        shared = nil
    }
}
