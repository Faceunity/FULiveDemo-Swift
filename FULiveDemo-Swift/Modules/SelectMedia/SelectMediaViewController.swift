//
//  SelectMediaViewController.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/24.
//

import UIKit
import MobileCoreServices

class SelectMediaViewController: UIViewController {
    
    private lazy var selectImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "select_image_icon"), for: .normal)
        button.setBackgroundImage(UIImage(named: "select_background"), for: .normal)
        button.setTitle(NSLocalizedString("选择图片", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.6), for: .highlighted)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(selectImageAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectVideoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "select_video_icon"), for: .normal)
        button.setBackgroundImage(UIImage(named: "select_background"), for: .normal)
        button.setTitle(NSLocalizedString("选择视频", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.6), for: .highlighted)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(selectVideoAction), for: .touchUpInside)
        return button
    }()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: UI
    
    private func configureUI() {
        view.backgroundColor = .black
        
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
        
        view.addSubview(selectImageButton)
        view.addSubview(selectVideoButton)
        
        selectImageButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 235, height: 48))
        }
        
        selectVideoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(selectImageButton.snp_bottom).offset(44)
            make.size.equalTo(CGSize(width: 235, height: 48))
        }
        
        let tipLabel = UILabel()
        tipLabel.textColor = .white
        tipLabel.font = .systemFont(ofSize: 17)
        tipLabel.text = NSLocalizedString("请从相册中选择图片或视频", comment: "")
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(selectImageButton.snp_top).offset(-44)
        }
        
    }
    
    //MARK: Private methods
    
    private func showImagePicker(mediaType: String) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.mediaTypes = [mediaType]
        present(picker, animated: true)
        
    }
    
    //MARK: Event response
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func selectImageAction() {
        showImagePicker(mediaType: kUTTypeImage as String)
    }
    
    @objc private func selectVideoAction() {
        showImagePicker(mediaType: kUTTypeMovie as String)
    }

}

extension SelectMediaViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) {
            let mediaType: String = info[.mediaType] as! String
            if mediaType == String(kUTTypeMovie) {
//                guard let videoURL = info[.mediaURL] else { return }
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
