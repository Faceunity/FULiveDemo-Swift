//
//  BeautyCategoriesView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/13.
//

import UIKit

@objc protocol BeautyCategoriesViewDelegate {
     func beautyCategoriesViewDidChangeCategory(newCategory: BeautyCategory, oldCategory:BeautyCategory)
}

class BeautyCategoriesView: UIView {
    
    weak var delegate: BeautyCategoriesViewDelegate?
    
    private let categoryCellIdentifer = "BeautyCategoryCell"
    
    lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3.0, height: 49)
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BeautyCategoryCell.self, forCellWithReuseIdentifier: categoryCellIdentifer)
        return collectionView
    }()
    
    var categoriesViewModel: BeautyCategoriesViewModel!
    
    init(frame: CGRect, viewModel: BeautyCategoriesViewModel) {
        super.init(frame: frame)
        
        categoriesViewModel = viewModel
        
        backgroundColor = UIColor(red: 5/225.0, green: 15/255.0, blue: 20/255.0, alpha: 1.0)
        
        addSubview(categoriesCollectionView)
        categoriesCollectionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(49)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(white: 1, alpha: 0.2)
        addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectCategory(category: BeautyCategory) {
        DispatchQueue.main.async {
            self.categoriesCollectionView.selectItem(at: IndexPath(item: category.rawValue, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            self.collectionView(self.categoriesCollectionView, didSelectItemAt: IndexPath(item: category.rawValue, section: 0))
        }
    }

}

extension BeautyCategoriesView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BeautyCategory.none.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellIdentifer, for: indexPath) as! BeautyCategoryCell
        let title = NSLocalizedString(BeautyCategory(rawValue: indexPath.item)!.name, tableName: "Beauty", bundle: .main, value: "", comment: "")
        cell.categoryLabel.text = title
        // cell.categoryLabel
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 保存旧索引
        let oldCategory = categoriesViewModel.selectedCategory
        if indexPath.item == categoriesViewModel.selectedCategory.rawValue {
            // 选择已经选中的，需要取消选择
            categoriesViewModel.selectedCategory = .none
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            // 选择其他的
            categoriesViewModel.selectedCategory = BeautyCategory(rawValue: indexPath.item)!
        }
        if let delegate = delegate {
            delegate.beautyCategoriesViewDidChangeCategory(newCategory: categoriesViewModel.selectedCategory, oldCategory: oldCategory)
        }
    }
}

class BeautyCategoryCell: UICollectionViewCell {
    lazy var categoryLabel: UILabel = {
        let category = UILabel()
        category.font = .systemFont(ofSize: 13)
        category.textColor = .white
        return category
    }()
    
    private var cellSelected: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        set {
            self.cellSelected = newValue
            categoryLabel.textColor = newValue ? UIColor(red: 94/255.0, green: 199/255.0, blue: 254/255.0, alpha: 1) : .white
        }
        get {
            return self.cellSelected
        }
    }
    
}
