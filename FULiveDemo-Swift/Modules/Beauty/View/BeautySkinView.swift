//
//  BeautyParametersView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/14.
//

import FURenderKit
import UIKit

@objc protocol BeautySkinViewDelegate {
    func beautyParametersView(view: BeautySkinView, changedSliderValueAt index: Int)
    func beautyParametersViewDidSetDefaultValue(view: BeautySkinView)
}

class BeautySkinView: UIView {
    weak var delegate: BeautySkinViewDelegate?
    // 美肤 or 美型
    var beautyCategory: BeautyCategory = .skin
    private let beautyParameterCellIdentifier = "BeautyParameterCell"
    
    lazy var segmentedControl: SegmentedControl = {
        let view = SegmentedControl(
            frame: CGRect(x: 0, y: 0, width: 100, height: 20),
            items: ["全局", "仅皮肤"]
        )
        // 设置样式
        view.titleColor = .white
        view.selectedTitleColor = .black
        view.titleFont = .systemFont(ofSize: 10, weight: .medium)

        // 设置回调
        view.shouldSelectItem = { index in
            if FURenderKit.devicePerformanceLevel().rawValue < 4 && index == 1 {
                let toast = String(format: NSLocalizedString("功能仅支持iPhone11及以上机型使用", tableName: "Beauty", bundle: .main, value: "", comment: ""), NSLocalizedString("皮肤美白", tableName: "Beauty", bundle: .main, value: "", comment: ""))
                AutoDismissToast.show(toast)
                return false
            }
            return true
        }

        view.didSelectItem = { [weak self] index in
            guard let self = self else { return }
            let model = self.parametersViewModel.beautyParameters[self.parametersViewModel.selectedIndex]
            model.enableSkinSegmentation = index == 0 ? false : true
            self.setEnableSkinSegmentation(eable: index == 0 ? false : true)
        }
        view.isHidden = true
        return view
    }()

    lazy var slider: LiveSlider = {
        let slider = LiveSlider(frame: CGRect(x: 40, y: 16, width: frame.width - 112, height: 30))
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderChangeEnded), for: [.touchUpInside, .touchUpOutside])
        slider.defaultValueInMiddle = false
        slider.isHidden = true
        return slider
    }()
    
    lazy var recoverButton: SquareButton = {
        let button = SquareButton(frame: CGRect(x: 0, y: 0, width: 44, height: 60), spacing: 8)
        button.setTitle(NSLocalizedString("恢复", comment: ""), for: .normal)
        button.setImage(UIImage(named: "recover"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10)
        button.titleLabel?.textAlignment = .center
        button.alpha = 0.6
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(recoverAction), for: .touchUpInside)
        return button
    }()
    
    lazy var parameterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 44, height: 74)
        layout.minimumLineSpacing = 22
        layout.minimumInteritemSpacing = 22
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 6, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BeautyParameterCell.self, forCellWithReuseIdentifier: beautyParameterCellIdentifier)
        return collectionView
    }()
    
    var parametersViewModel: BeautySkinViewModel!
    
    init(frame: CGRect, viewModel: BeautySkinViewModel) {
        super.init(frame: frame)
        
        parametersViewModel = viewModel
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setEnableSkinSegmentation(eable: Bool) {
        if let beauty = FURenderKit.share().beauty {
            beauty.enableSkinSegmentation = eable
        }
    }
    
    func refreshOnViewWillAppear() {
        if parametersViewModel.enableSkinSegmentation() {
            segmentedControl.selectedIndex = 1
            setEnableSkinSegmentation(eable: true)
        }
    }
    
    func reloadSubviews(params: [BeautySkinModel]) {
        parametersViewModel.beautyParameters = params
        sliderChangeEnded()
    }
    
    // MARK: UI
    
    private func configureUI() {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        addSubview(effectView)
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(21)
            make.size.equalTo(CGSize(width: 70, height: 20))
        }
        
        addSubview(slider)
        slider.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.top.equalTo(16)
            make.height.equalTo(30)
        }
        
        addSubview(recoverButton)
        recoverButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.bottom.equalToSuperview().offset(-19)
            make.size.equalTo(CGSize(width: 44, height: 60))
        }
        
        let verticalLine = UIView()
        verticalLine.backgroundColor = UIColor(white: 1, alpha: 0.2)
        addSubview(verticalLine)
        verticalLine.snp.makeConstraints { make in
            make.leading.equalTo(recoverButton.snp_trailing).offset(14)
            make.centerY.equalTo(recoverButton.snp_centerY)
            make.size.equalTo(CGSize(width: 1, height: 24))
        }
        
        addSubview(parameterCollectionView)
        parameterCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(76)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(98)
        }
    }
    
    // MARK: Event response
    
    @objc private func sliderValueChanged() {
        // 赋值给model
        let model = parametersViewModel.beautyParameters[parametersViewModel.selectedIndex]
        model.currentValue = beautyCategory == BeautyCategory.skin ? Double(slider.value * model.ratio) : Double(slider.value)
        // 回调
        if let delegate = delegate {
            delegate.beautyParametersView(view: self, changedSliderValueAt: parametersViewModel.selectedIndex)
        }
    }
    
    @objc private func sliderChangeEnded() {
        // 滑动结束
        DispatchQueue.main.async {
            if self.parametersViewModel.isDefaultValue {
                self.recoverButton.alpha = 0.6
                self.recoverButton.isUserInteractionEnabled = false
            } else {
                self.recoverButton.alpha = 1
                self.recoverButton.isUserInteractionEnabled = true
            }
            self.parameterCollectionView.reloadData()
            guard self.parametersViewModel.selectedIndex >= 0 && self.parametersViewModel.selectedIndex < self.parametersViewModel.beautyParameters.count else { return }
            self.parameterCollectionView.selectItem(at: IndexPath(item: self.parametersViewModel.selectedIndex, section: 0), animated: false, scrollPosition: .top)
        }
    }
    
    @objc private func recoverAction() {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("是否将所有参数恢复到默认值", comment: ""), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel)
        let certainAction = UIAlertAction(title: "确定", style: .default) { _ in
            self.parametersViewModel.setParametersToDefaults()
            // 更新各控件状态
            DispatchQueue.main.async {
                self.sliderChangeEnded()
                if self.parametersViewModel.selectedIndex >= 0 {
                    let model = self.parametersViewModel.beautyParameters[self.parametersViewModel.selectedIndex]
                    self.slider.value = self.beautyCategory == BeautyCategory.skin ? Float(model.currentValue)/model.ratio : Float(model.currentValue)
                }
            }
            if let delegate = self.delegate {
                delegate.beautyParametersViewDidSetDefaultValue(view: self)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(certainAction)
        UIApplication.topViewController()?.present(alert, animated: true)
    }
}

extension BeautySkinView: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parametersViewModel.beautyParameters!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: beautyParameterCellIdentifier, for: indexPath) as! BeautyParameterCell
        let parameter = parametersViewModel.beautyParameters[indexPath.item]
        cell.parameter = parameter
        cell.textLabel.text = NSLocalizedString(parameter.name, comment: "")
        cell.disabled = parameter.performanceLevel > FURenderKit.devicePerformanceLevel().rawValue
        cell.isSelected = indexPath.item == parametersViewModel.selectedIndex
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let model = parametersViewModel.beautyParameters[indexPath.item]
        let disable = model.performanceLevel > FURenderKit.devicePerformanceLevel().rawValue
        if disable {
            var toast = ""
            if beautyCategory == .shape {
                toast = String(format: NSLocalizedString("该功能只支持在高端机上使用", tableName: "Beauty", bundle: .main, value: "", comment: ""), model.name)
            } else {
                if model.performanceLevel == 3 {
                    toast = String(format: NSLocalizedString("功能仅支持iPhoneXR及以上机型使用", tableName: "Beauty", bundle: .main, value: "", comment: ""), model.name)

                } else if model.performanceLevel >= 1 {
                    toast = String(format: NSLocalizedString("该功能只支持在高端机上使用", tableName: "Beauty", bundle: .main, value: "", comment: ""), model.name)
                }
            }
            AutoDismissToast.show(toast)
            
            collectionView.reloadData()
            if parametersViewModel.selectedIndex >= 0 {
                collectionView.selectItem(at: IndexPath(item: parametersViewModel.selectedIndex, section: 0), animated: false, scrollPosition: [])
            }
        }
        
        return disable ? false : true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        parametersViewModel.selectedIndex = indexPath.item
        slider.isHidden = false
        let model = parametersViewModel.beautyParameters[parametersViewModel.selectedIndex]
        
        slider.defaultValueInMiddle = model.defaultValueInMiddle
        slider.value = beautyCategory == BeautyCategory.skin ? Float(model.currentValue)/model.ratio : Float(model.currentValue)
        
        updateSegView()
    }
}

extension BeautySkinView {
    func updateSegView() {
        let model = parametersViewModel.beautyParameters[parametersViewModel.selectedIndex]
        if beautyCategory == BeautyCategory.skin, model.type == BeautySkin.colorLevel.rawValue {
            segmentedControl.isHidden = false
            slider.snp.remakeConstraints { make in
                make.left.equalTo(segmentedControl.snp.right).offset(10)
                make.right.equalTo(-40)
                make.top.equalTo(16)
                make.height.equalTo(30)
            }
        } else {
            segmentedControl.isHidden = true
            slider.snp.remakeConstraints { make in
                make.left.equalTo(40)
                make.right.equalTo(-40)
                make.top.equalTo(16)
                make.height.equalTo(30)
            }
        }
    }
}

class BeautyParameterCell: UICollectionViewCell {
    var imageView: UIImageView!
    var textLabel: UILabel!
    var disabled: Bool = false
    
    var parameter: BeautySkinModel!
    
    private var cellSelected: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(snp_width)
        }
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 3.0
        
        textLabel = UILabel()
        textLabel.textColor = .white
        textLabel.font = .systemFont(ofSize: 10)
        textLabel.textAlignment = .center
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp_bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        set {
            cellSelected = newValue
            
            if disabled {
                imageView.image = UIImage(named: String(format: "%@-0", parameter.name))
                imageView.alpha = 0.7
                textLabel.alpha = 0.7
            } else {
                imageView.alpha = 1
                textLabel.alpha = 1
                
                var changed = false
                if parameter.defaultValueInMiddle {
                    changed = fabs(parameter.currentValue - 0.5) > 0.01
                } else {
                    changed = parameter.currentValue > 0.01
                }
                if newValue {
                    imageView.image = changed ? UIImage(named: String(format: "%@-3", parameter.name)) : UIImage(named: String(format: "%@-2", parameter.name))
                    textLabel.textColor = UIColor(redValue: 94, greenValue: 199, blueValue: 254)
                } else {
                    imageView.image = changed ? UIImage(named: String(format: "%@-1", parameter.name)) : UIImage(named: String(format: "%@-0", parameter.name))
                    textLabel.textColor = .white
                }
            }
        }
        get {
            return cellSelected
        }
    }
}
