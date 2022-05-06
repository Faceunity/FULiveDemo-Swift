//
//  BeautyStylesView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/14.
//

import UIKit

@objc protocol BeautyStylesViewDelegate {
    func beautyStyleView(view: BeautyStylesView, didSelectAt index: Int)
}

class BeautyStylesView: UIView {
    
    weak var delegate: BeautyStylesViewDelegate?
    
    private let beautyStyleCellIdentifier = "BeautyFilterCell"
    
    lazy var styleCollectionView: UICollectionView = {
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
        collectionView.register(BeautyStyleCell.self, forCellWithReuseIdentifier: beautyStyleCellIdentifier)
        return collectionView
    }()
    
    var stylesViewModel: BeautyStylesViewModel!
    
    init(frame: CGRect, viewModel: BeautyStylesViewModel) {
        
        super.init(frame: frame)
        
        stylesViewModel = viewModel
        
        configureUI()
        
        selectStyle(index: self.stylesViewModel.selectedIndex)
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
        
        addSubview(styleCollectionView)
        styleCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(98)
        }
    }
    
    func selectStyle(index: Int) {
        guard index >= 0 && index < stylesViewModel.beautyStyles.count else { return }
        stylesViewModel.selectedIndex = index
        DispatchQueue.main.async {
            self.styleCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
        
    }
}

extension BeautyStylesView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stylesViewModel.beautyStyles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: beautyStyleCellIdentifier, for: indexPath) as! BeautyStyleCell
        let style = stylesViewModel.beautyStyles[indexPath.item]
        cell.textLabel.text = NSLocalizedString(style.name, comment: "")
        cell.imageName = style.name
        cell.isSelected = indexPath.item == stylesViewModel.selectedIndex
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stylesViewModel.selectedIndex = indexPath.item
        if let delegate = delegate {
            delegate.beautyStyleView(view: self, didSelectAt: stylesViewModel.selectedIndex)
        }
    }
}

class BeautyStyleCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var textLabel: UILabel!
    
    var imageName: String?
    
    private var cellSelected: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(snp_width)
        }
        
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
            if newValue {
                if let imageName = imageName {
                    imageView.image = UIImage.localizedImage(name: String(format: "%@-2", imageName))
                }
                textLabel.textColor = UIColor(redValue: 94, greenValue: 199, blueValue: 254)
            } else {
                if let imageName = imageName {
                    imageView.image = UIImage.localizedImage(name: String(format: "%@-0", imageName))
                }
                textLabel.textColor = .white
            }
        }
        get {
            return self.cellSelected
        }
    }
}
