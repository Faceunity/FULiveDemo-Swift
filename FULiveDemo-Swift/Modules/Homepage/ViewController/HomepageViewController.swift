//
//  HomepageViewController.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/6.
//

import UIKit
import SnapKit

class HomepageViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let collectionCellIdentifier = "HomepageCollectionViewCell"
    private let collectionHeaderReusableViewIdentifier = "HomepageHeaderReusableView"
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomepageCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        collectionView.register(HomepageHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderReusableViewIdentifier)
        return collectionView
    }()
    
    var viewModel: HomepageViewModel!
    
    //MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "090017")
        
        // 初始化FURenderKit
        Manager.shared.setupRenderKit()
        
        viewModel = HomepageViewModel()
        
        configureUI()
    }
    
    //MARK: UI
    
    func configureUI() {
        let statusHeight = UIApplication.shared.statusBarFrame.height
        let navigationView = HomepageNavigationView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44 + statusHeight))
        view .addSubview(navigationView)
        navigationView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(44 + statusHeight)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp_bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        // 顶部背景图
        let topImageWidth = collectionView.bounds.width
        let topImageHeight = topImageWidth * 456 / 750
        collectionView.contentInset = UIEdgeInsets(top: topImageHeight, left: 0, bottom: 0, right: 0)
        let topImageView = UIImageView(image: UIImage(named: "homepage_top_background"))
        topImageView.frame = CGRect(x: 0, y: -topImageHeight, width: topImageWidth, height: topImageHeight)
        collectionView.addSubview(topImageView)
    }

}

extension HomepageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.homepageDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let modules = viewModel.homepageDataSource[section]
        return modules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! HomepageCollectionViewCell
        let model = viewModel.homepageDataSource[indexPath.section][indexPath.item]
        cell.textLabel.text = model.name
        cell.imageView.image = UIImage(named: model.icon!)
        if model.enabled == true {
            cell.bottomImageView.image = UIImage(named: "bottom_image_enabled")
        } else {
            cell.bottomImageView.image = UIImage(named: "bottom_image_disabled")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderReusableViewIdentifier, for: indexPath) as! HomepageHeaderReusableView
            headerView.textLabel.text = NSLocalizedString(ModuleCategory(rawValue: indexPath.section)!.title, comment: "")
            return headerView
        }
        return UICollectionReusableView()
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = viewModel.homepageDataSource[indexPath.section][indexPath.item]
        guard model.enabled == true else {
            return
        }
        switch ModuleType(rawValue: model.type!) {
        case .beauty:
            let beautyController = BeautyViewController(viewModel: BeautyViewModel())
            navigationController?.pushViewController(beautyController, animated: true)
        default: break
        }
    }
    
    
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width / 3.0 - 24.0
        let height = width / 101.0 * 122
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
