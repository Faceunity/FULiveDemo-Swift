//
//  BeautyViewController.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/12.
//

import CoreMIDI
import FURenderKit
import UIKit

class BeautyViewController: BaseViewController<BeautyViewModel> {
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BeautyViewManager.sharedManager().viewModel = viewModel
        BeautyViewManager.sharedManager().addToTargetView(view: view)
        BeautyViewManager.sharedManager().beautyView.captureDelegate = self
        BeautyViewManager.sharedManager().beautyView.onViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 更新美颜缓存
        BeautyViewManager.sharedManager().beautyView.onViewWillDisappear()
        BeautyViewManager.destroy()
    }
    
    // MARK: PopMenuDelegate
    
    override func popMenuDidClickSelectingMedia() {
        let selectMediaController = SelectMediaViewController()
        navigationController?.pushViewController(selectMediaController, animated: true)
    }
}
