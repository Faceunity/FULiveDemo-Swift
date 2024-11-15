//
//  GestureRecognitionViewController.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/4.
//

import FURenderKit
import UIKit

class GestureRecognitionViewController: BaseViewController<GestureRecognitionViewModel> {
    private var currentGesture: FUGesture?
    private var selectIndex: Int = 1
    private var items: [HorizontalScrollViewItem] = []

    override var functionTypes: [HeaderFunctionType] {
        return [.back, .switchFormat, .bugly, .switchCamera]
    }

    private let gestureRecognitionTips: [String: String] = [
        "ssd_thread_thumb": "竖个拇指",
        "ssd_thread_six": "比个六",
        "ssd_thread_cute": "双拳靠近脸颊卖萌",
        "ssd_thread_korheart": "单手手指比心",
        "ctrl_rain_740": "推出手掌",
        "ctrl_snow_740": "推出手掌",
        "ctrl_flower_740": "推出手掌",
    ]

    private lazy var horizontalScrollView: HorizontalScrollView = {
        let view = HorizontalScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80))
        return view
    }()

    private func setupUI() {
        view.addSubview(horizontalScrollView)
        horizontalScrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }

    private func configureData() {
        items = [
            HorizontalScrollViewItem(id: "reset_item", imageName: "reset_item"),
            HorizontalScrollViewItem(id: "ctrl_rain_740", imageName: "ctrl_rain_740"),
            HorizontalScrollViewItem(id: "ctrl_snow_740", imageName: "ctrl_snow_740"),
            HorizontalScrollViewItem(id: "ctrl_flower_740", imageName: "ctrl_flower_740"),
            HorizontalScrollViewItem(id: "ssd_thread_korheart", imageName: "ssd_thread_korheart"),
            HorizontalScrollViewItem(id: "ssd_thread_six", imageName: "ssd_thread_six"),
            HorizontalScrollViewItem(id: "ssd_thread_cute", imageName: "ssd_thread_cute"),
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

    override func viewWillAppear(_ animated: Bool) {
        horizontalScrollView(horizontalScrollView, didSelectItemAt: selectIndex)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if currentGesture != nil {
            FURenderKit.share().stickerContainer.removeAllSticks()
            currentGesture = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCaptureButtonBottomConstraint(constraint: 90, animated: false)
        configureData()

        // 设置检测手势
        viewModel.aiTraceType = .Hand
        // 加载 AImodel
        Manager.shared.loadHandAIModel()
    }

    deinit {
        Manager.shared.unloadHandAIModel()
    }
}

extension GestureRecognitionViewController: HorizontalScrollViewDelegate {
    func horizontalScrollView(_ scrollView: HorizontalScrollView, didSelectItemAt index: Int) {
        selectIndex = index
        if index == 0 {
            FURenderKit.share().stickerContainer.removeAllSticks()
            currentGesture = nil
            traceLabel.isHidden = true
        } else {
            let itemId = items[index].id
            let path = Bundle.main.path(forResource: itemId, ofType: "bundle")!
            let gesture = FUGesture(path: path, name: "FUGesture")
            if itemId == "ssd_thread_korheart" {
                // 比心道具手动调整下
                gesture.handOffY = -100
            }

            if currentGesture != nil {
                FURenderKit.share().stickerContainer.replace(currentGesture!, with: gesture) {
                    self.currentGesture = gesture
                }
            } else {
                FURenderKit.share().stickerContainer.add(gesture) {
                    self.currentGesture = gesture
                }
            }

            // 提示
            AutoDismissToast.showType1(gestureRecognitionTips[items[index].id]!)
        }
    }
}
