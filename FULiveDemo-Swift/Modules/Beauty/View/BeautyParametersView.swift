//
//  BeautyParametersView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/14.
//

import UIKit

@objc protocol BeautyParametersViewDelegate {
    func beautyParametersView(view: BeautyParametersView, changedSliderValueAt index: Int)
    func beautyParametersViewDidSetDefaultValue(view: BeautyParametersView)
}

class BeautyParametersView: UIView {
    
    weak var delegate: BeautyParametersViewDelegate?
    
    private let beautyParameterCellIdentifier = "BeautyParameterCell"
    
    lazy var slider: LiveSlider = {
        let slider = LiveSlider(frame: CGRect(x: 56, y: 16, width: frame.width - 112, height: 30))
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
        layout.itemSize = CGSize(width: 54, height: 70)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 50
        layout.sectionInset = UIEdgeInsets(top: 16, left: 18, bottom: 10, right: 18)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BeautyParameterCell.self, forCellWithReuseIdentifier: beautyParameterCellIdentifier)
        return collectionView
    }()
    
    var parametersViewModel: BeautyParametersViewModel!
    
    init(frame: CGRect, viewModel: BeautyParametersViewModel) {

        super.init(frame: frame)
        
        parametersViewModel = viewModel
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadSubviews(params: [BeautyParameterModel]) {
        parametersViewModel.beautyParameters = params
        sliderChangeEnded()
    }
    
    //MARK: UI
    
    private func configureUI() {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        addSubview(effectView)
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(slider)
        
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
    
    //MARK: Event response
    
    @objc private func sliderValueChanged() {
        // 赋值给model
        let model = parametersViewModel.beautyParameters[parametersViewModel.selectedIndex]
        model.currentValue = Double(slider.value * model.ratio)
        // 回调
        if let delegate = delegate {
            delegate.beautyParametersView(view: self, changedSliderValueAt: parametersViewModel.selectedIndex)
        }
    }
    
    @objc private func sliderChangeEnded() {
        // 滑动结束
        DispatchQueue.main.async {
            if (self.parametersViewModel.isDefaultValue) {
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
        cancelAction.setValue(UIColor(redValue: 44, greenValue: 46, blueValue: 48), forKey: "titleTextColor")
        let certainAction = UIAlertAction(title: "确定", style: .default) { action in
            self.parametersViewModel.setParametersToDefaults()
            // 更新各控件状态
            DispatchQueue.main.async {
                self.sliderChangeEnded()
                if self.parametersViewModel.selectedIndex >= 0 {
                    let model = self.parametersViewModel.beautyParameters[self.parametersViewModel.selectedIndex]
                    self.slider.value = Float(model.currentValue)/model.ratio
                }
            }
            if let delegate = self.delegate {
                delegate.beautyParametersViewDidSetDefaultValue(view: self)
            }
        }
        certainAction.setValue(UIColor(redValue: 31, greenValue: 178, blueValue: 255), forKey: "titleTextColor")
        alert.addAction(cancelAction)
        alert.addAction(certainAction)
        UIApplication.topViewController()?.present(alert, animated: true)
        
    }
}

extension BeautyParametersView: UICollectionViewDataSource, UICollectionViewDelegate {
    //MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parametersViewModel.beautyParameters!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: beautyParameterCellIdentifier, for: indexPath) as! BeautyParameterCell
        let parameter = parametersViewModel.beautyParameters[indexPath.item]
        cell.parameter = parameter
        cell.textLabel.text = NSLocalizedString(parameter.name, comment: "")
        cell.isSelected = indexPath.item == parametersViewModel.selectedIndex
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        parametersViewModel.selectedIndex = indexPath.item
        slider.isHidden = false
        let model = parametersViewModel.beautyParameters[parametersViewModel.selectedIndex]
        
        slider.defaultValueInMiddle = model.defaultValueInMiddle
        slider.value = Float(model.currentValue)/model.ratio
    }
}

class BeautyParameterCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var textLabel: UILabel!
    
    var parameter: BeautyParameterModel!
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        set {
            self.cellSelected = newValue
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
        get {
            return self.cellSelected
        }
    }
}

