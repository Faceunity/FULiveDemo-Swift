//
//  StickerView.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/5.
//

import FURenderKit
import SVProgressHUD
import UIKit

class StickerView: UIView {
    private var currentSticker: FUSticker?
    private var selectIndex: Int = 1
    private var items: [HorizontalScrollViewItem] = []

    private lazy var horizontalScrollView: HorizontalScrollView = {
        let view = HorizontalScrollView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 80))
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureData()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        configureData()
    }

    private func setupUI() {
        addSubview(horizontalScrollView)
        horizontalScrollView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }

    private func configureData() {
        items = [
            HorizontalScrollViewItem(id: "reset_item", imageName: "reset_item"),
            HorizontalScrollViewItem(id: "CatSparks", imageName: "CatSparks"),
            HorizontalScrollViewItem(id: "fu_zh_fenshu", imageName: "fu_zh_fenshu"),
            HorizontalScrollViewItem(id: "sdlr", imageName: "sdlr"),
            HorizontalScrollViewItem(id: "xlong_zh_fu", imageName: "xlong_zh_fu"),
            HorizontalScrollViewItem(id: "newy1", imageName: "newy1"),
            HorizontalScrollViewItem(id: "redribbt", imageName: "redribbt"),
            HorizontalScrollViewItem(id: "DaisyPig", imageName: "DaisyPig"),
            HorizontalScrollViewItem(id: "sdlu", imageName: "sdlu"),
        ]
        horizontalScrollView.configure(
            items: items,
            showType: .round,
            itemSpace: 8,
            imageWidth: 60,
            showTitle: false,
            selectedIndex: selectIndex,
            delegate: self
        )
    }

    // MARK: controller 生命周期函数回调

    func onViewWillAppear() {
        horizontalScrollView(horizontalScrollView, didSelectItemAt: selectIndex)
    }

    func onViewWillDisAppear() {
        if currentSticker != nil {
            FURenderKit.share().stickerContainer.removeAllSticks()
            currentSticker = nil
        }
    }
}

// MARK: 代理回调

extension StickerView: HorizontalScrollViewDelegate {
    func horizontalScrollView(_ scrollView: HorizontalScrollView, didSelectItemAt index: Int) {
        selectIndex = index
        if index == 0 {
            FURenderKit.share().stickerContainer.removeAllSticks()
            currentSticker = nil
        } else {
            let path = Bundle.main.path(forResource: items[index].id, ofType: "bundle")!
            let sticker = FUSticker(path: path, name: "FUSticker")

            if currentSticker != nil {
                FURenderKit.share().stickerContainer.replace(currentSticker!, with: sticker) {
                    self.currentSticker = sticker
                }
            } else {
                FURenderKit.share().stickerContainer.add(sticker) {
                    self.currentSticker = sticker
                }
            }
        }
    }
}
