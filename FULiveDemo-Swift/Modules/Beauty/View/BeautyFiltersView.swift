//
//  BeautyFiltersView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/14.
//

import UIKit

@objc protocol BeautyFiltersViewDelegate {
    func beautyFiltersView(view: BeautyFiltersView, didSelectAt index: Int)
    func beautyFiltersView(view: BeautyFiltersView, changedSliderValueAt index: Int)
}

class BeautyFiltersView: UIView {
    
    weak var delegate: BeautyFiltersViewDelegate?
    
    private let beautyFilterCellIdentifier = "BeautyFilterCell"
    
    lazy var slider: LiveSlider = {
        let slider = LiveSlider(frame: CGRect(x: 56, y: 16, width: frame.width - 112, height: 30))
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.defaultValueInMiddle = false
        slider.isHidden = true
        return slider
    }()
    
    lazy var filterCollectionView: UICollectionView = {
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
        collectionView.register(BeautyFilterCell.self, forCellWithReuseIdentifier: beautyFilterCellIdentifier)
        return collectionView
    }()
    
    var filtersViewModel: BeautyFiltersViewModel!
    
    init(frame: CGRect, viewModel: BeautyFiltersViewModel) {
        
        super.init(frame: frame)
        
        filtersViewModel = viewModel
        
        configureUI()
        
        selectFilter(filter: viewModel.beautyFilters[viewModel.selectedIndex])
        
        updateSliderStatus()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        addSubview(filterCollectionView)
        filterCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(98)
        }

    }
    
    private func updateSliderStatus() {
        DispatchQueue.main.async {
            self.slider.isHidden = self.filtersViewModel.selectedIndex <= 0
            self.slider.value = Float(self.filtersViewModel.beautyFilters[self.filtersViewModel.selectedIndex].value)
        }
    }
    
    func selectFilter(filter: BeautyFilterModel) {
        let currentFilter = filtersViewModel.beautyFilters[filtersViewModel.selectedIndex]
        if filter.index != currentFilter.index || fabs(filter.value - currentFilter.value) > 0.01 {
            filtersViewModel.beautyFilters[filter.index] = filter
            filtersViewModel.selectedIndex = filter.index
        }
        DispatchQueue.main.async {
            self.filterCollectionView.selectItem(at: IndexPath(item: filter.index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    //MARK: Event response
    
    @objc private func sliderValueChanged() {
        filtersViewModel.beautyFilters[filtersViewModel.selectedIndex].value = Double(slider.value)
        if let delegate = delegate {
            delegate.beautyFiltersView(view: self, changedSliderValueAt: filtersViewModel.selectedIndex)
        }
    }
}

extension BeautyFiltersView: UICollectionViewDataSource, UICollectionViewDelegate {
    //MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtersViewModel.beautyFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: beautyFilterCellIdentifier, for: indexPath) as! BeautyFilterCell
        let filter = filtersViewModel.beautyFilters[indexPath.item]
        cell.imageView.image = UIImage(named: filter.name)
        cell.textLabel.text = NSLocalizedString(filter.name, comment: "")
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filtersViewModel.selectedIndex = indexPath.item
        slider.isHidden = indexPath.item <= 0
        slider.value = Float(filtersViewModel.beautyFilters[filtersViewModel.selectedIndex].value)
        if let delegate = delegate {
            delegate.beautyFiltersView(view: self, didSelectAt: filtersViewModel.selectedIndex)
        }
    }
}

class BeautyFilterCell: UICollectionViewCell {
    var imageView: UIImageView!
    var textLabel: UILabel!
    
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
    
    override var isSelected: Bool {
        set {
            self.cellSelected = newValue
            imageView.layer.borderWidth = newValue ? 2 : 0
            imageView.layer.borderColor = newValue ? UIColor(redValue: 94, greenValue: 199, blueValue: 254).cgColor : UIColor.clear.cgColor
            textLabel.textColor = newValue ? UIColor(redValue: 94, greenValue: 199, blueValue: 254) : .white
        }
        get {
            return self.cellSelected
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
