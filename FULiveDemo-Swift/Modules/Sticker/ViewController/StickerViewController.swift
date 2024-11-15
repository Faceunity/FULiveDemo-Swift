//
//  StickerViewController.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/4.
//

import FURenderKit
import UIKit

class StickerViewController: BaseViewController<StickerViewModel> {
    override var functionTypes: [HeaderFunctionType] {
        return [.back, .switchFormat, .bugly, .switchCamera]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateCaptureButtonBottomConstraint(constraint: 90, animated: false)
        StickerViewManager.sharedManager().addToTargetView(view: view)
        StickerViewManager.sharedManager().stickerView.onViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        StickerViewManager.destroy()
    }
}
