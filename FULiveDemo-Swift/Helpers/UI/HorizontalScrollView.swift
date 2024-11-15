//
//  HorizontalScrollView.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/4.
//

import UIKit

struct HorizontalScrollViewItem {
    let id: String
    let imageName: String?
    let imgBgColor: UIColor?
    let label: String?
    
    init(id: String, imageName: String? = nil, imgBgColor: UIColor? = nil, label: String? = nil) {
        self.id = id
        self.imageName = imageName
        self.imgBgColor = imgBgColor
        self.label = label
    }
}

enum HorizontalScrollViewItemShowType {
    case round
    case rectangle
}

protocol HorizontalScrollViewDelegate: AnyObject {
    func horizontalScrollView(_ scrollView: HorizontalScrollView, didSelectItemAt index: Int)
}

class HorizontalScrollView: UIView {
    weak var delegate: HorizontalScrollViewDelegate?
    
    private var itemSpace: CGFloat = 8
    private var imageWidth: CGFloat = 60
    private var items: [HorizontalScrollViewItem] = []
    private var selectedIndex: Int = 0
    private var showType: HorizontalScrollViewItemShowType = .round
    private var showTitle: Bool = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = itemSpace
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(ItemCell.self, forCellWithReuseIdentifier: "ItemCell")
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - 公开方法

    func configure(items: [HorizontalScrollViewItem],
                   showType: HorizontalScrollViewItemShowType = .round,
                   itemSpace: CGFloat = 8,
                   imageWidth: CGFloat = 60,
                   showTitle: Bool = false,
                   selectedIndex: Int = 0,
                   delegate: HorizontalScrollViewDelegate)
    {
        self.items = items
        self.showType = showType
        self.itemSpace = itemSpace
        self.imageWidth = imageWidth
        self.showTitle = showTitle
        self.selectedIndex = selectedIndex
        self.delegate = delegate
        
        collectionView.reloadData()
        
        // 滚动到选中位置
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if selectedIndex > 3 {
                self.collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0),
                                                 at: .centeredHorizontally,
                                                 animated: false)
            }
        }
    }
}

private extension HorizontalScrollView {
    func setupUI() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
}

extension HorizontalScrollView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let item = items[indexPath.item]
        cell.configure(with: item,
                       isSelected: selectedIndex == indexPath.item,
                       showType: showType,
                       showTitle: showTitle,
                       imageWidth: imageWidth)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
        delegate?.horizontalScrollView(self, didSelectItemAt: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageWidth, height: showTitle ? imageWidth + 25 : imageWidth)
    }
}

// MARK: - Collection View Cell

private class ItemCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configure(with item: HorizontalScrollViewItem,
                   isSelected: Bool,
                   showType: HorizontalScrollViewItemShowType,
                   showTitle: Bool,
                   imageWidth: CGFloat)
    {
        imageView.snp.updateConstraints { make in
            make.width.height.equalTo(imageWidth)
        }
        
        // 设置图片
        if let imageName = item.imageName {
            imageView.image = UIImage(named: imageName)
        }
        
        imageView.backgroundColor = item.imgBgColor
        titleLabel.text = item.label
        titleLabel.isHidden = !showTitle
        
        // 设置圆角
        imageView.layer.cornerRadius = showType == .round ? imageWidth/2 : 4
        if isSelected {
            imageView.layer.borderWidth = 4
            imageView.layer.borderColor = UIColor(red: 94/255, green: 199/255, blue: 254/255, alpha: 1).cgColor
        } else {
            imageView.layer.borderWidth = 0
        }
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.height.equalTo(60)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.centerX.equalTo(imageView)
            make.left.right.equalToSuperview()
        }
    }
}
