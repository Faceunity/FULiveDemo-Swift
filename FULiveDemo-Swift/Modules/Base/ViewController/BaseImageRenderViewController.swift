//
//  BaseMediaRenderingViewController.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/18.
//

import FURenderKit
import UIKit

class BaseImageRenderViewController<T: BaseImageRenderViewModel>: UIViewController {
    lazy var renderView: FUGLDisplayView = {
        let displayView = FUGLDisplayView(frame: view.bounds)
        displayView.contentMode = .scaleAspectFit
        return displayView
    }()
    
    lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setBackgroundImage(UIImage(named: "download"), for: .normal)
        button.layer.cornerRadius = 42.5
        button.addTarget(self, action: #selector(BaseImageRenderViewController.downloadAction), for: .touchUpInside)
        return button
    }()
    
    lazy var traceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17)
        label.text = NSLocalizedString("未检测到人脸", comment: "")
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    var viewModel: T
    
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        
        self.viewModel.faceTraceCallBack = { [weak self] (tracked: Bool) in
            if self?.viewModel.traceType == .None || tracked {
                DispatchQueue.main.async {
                    self?.traceLabel.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                    self?.traceLabel.isHidden = false
                    self?.traceLabel.text = self?.viewModel.traceType == .Face ? "未检测到人脸" : self?.viewModel.traceType == .Body ? "未检测到人体" : "未检测到手势"
                }
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    
        viewModel.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UI
    
    private func configureUI() {
        view.addSubview(renderView)
        renderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            } else {
                make.top.equalToSuperview().offset(30)
            }
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        view.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-69)
            } else {
                make.bottom.equalTo(view.snp_bottom).offset(-69)
            }
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 85, height: 85))
        }
        
        view.addSubview(traceLabel)
        traceLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 更新保存按钮UI
    /// - Parameter constraint: 距离底部高度
    func updateDownloadButtonBottomConstraint(constraint: CGFloat) {}
    
    // MARK: Event response
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func downloadAction() {
        viewModel.captureImageHandler = { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            AutoDismissToast.show("保存图片失败")
        } else {
            AutoDismissToast.show("图片已保存到相册")
        }
    }
    
    @objc func applicationWillResignActive() {
        viewModel.stop()
    }
    
    @objc func applicationDidBecomeActive() {
        viewModel.start()
    }
}

extension BaseImageRenderViewController: ImageRenderViewModelDelegate {
    func imageRenderDidOutput(pixelBuffer: CVPixelBuffer) {
        renderView.display(pixelBuffer)
    }
}
