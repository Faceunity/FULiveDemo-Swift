//
//  StickerViewModel.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/4.
//

import UIKit

class StickerViewModel: BaseViewModel {
    let beautyViewModel : BeautyViewModel
    
    override init() {
        // 加载美颜
        beautyViewModel = BeautyViewModel()
        beautyViewModel.loadItem()
        beautyViewModel.reloadBeautyParams()
        
        super.init()
    }
    
    deinit {
        if(beautyViewModel.beauty !== nil) {
            beautyViewModel.releaseItem()
        }
    }
}
