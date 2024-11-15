//
//  BeautyView.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/7.
//

import FURenderKit
import UIKit

private let kFunctionViewHeight: CGFloat = 146

class BeautyView: UIView {
    var viewModel: BeautyViewModel!
    weak var captureDelegate: CaptureDelegate? {
        didSet {
            captureButton.delegate = captureDelegate
        }
    }
    
    /// 底部功能分类视图
    lazy var categoriesView: BeautyCategoriesView = {
        let view = BeautyCategoriesView(frame: .zero, viewModel: BeautyCategoriesViewModel())
        view.delegate = self
        return view
    }()
    
    lazy var captureButton: CaptureButton = {
        let button = CaptureButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        return button
    }()
    
    /// 效果对比按钮
    lazy var compareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "demo_icon_contrast"), for: .normal)
        button.addTarget(self, action: #selector(compareTouchDownAction), for: .touchDown)
        button.addTarget(self, action: #selector(compareTouchUpAction), for: [.touchUpInside, .touchUpOutside])
        button.isHidden = true
        return button
    }()
    
    /// 美肤视图
    var skinView: BeautySkinView!
    
    /// 美型视图
    var shapeView: BeautySkinView!
    
    /// 滤镜视图
    var filterView: BeautyFiltersView!
     
    // MARK: Life cycle
    
    init(frame: CGRect, viewModel: BeautyViewModel) {
        super.init(frame: frame)
        self.viewModel = viewModel
        viewModel.loadItem()
        configureBeautyUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onViewWillAppear() {
        // 加载美颜缓存
        viewModel.reloadBeautyParams()
        
        // 加载美颜缓存之后需要更新UI
        skinView.reloadSubviews(params: viewModel.beautySkinParams)
        shapeView.reloadSubviews(params: viewModel.beautyShapeParams)
        if viewModel.selectedFilter != nil {
            filterView.selectFilter(filter: viewModel.selectedFilter)
        }
        
        updateCaptureButtonBottomConstraint(constraint: 10)

        // 设置人脸分割
        skinView.refreshOnViewWillAppear()
    }
    
    func onViewWillDisappear() {
        // 更新美颜缓存
        viewModel.cacheBeautyParams()
        viewModel.releaseItem()
    }
    
    // MARK: UI
    
    private func configureBeautyUI() {
        skinView = BeautySkinView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kFunctionViewHeight), viewModel: BeautySkinViewModel(parameters: viewModel.beautySkinParams))
        skinView.beautyCategory = BeautyCategory.skin
        skinView.delegate = self
        shapeView = BeautySkinView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kFunctionViewHeight), viewModel: BeautySkinViewModel(parameters: viewModel.beautyShapeParams))
        shapeView.beautyCategory = BeautyCategory.shape
        shapeView.delegate = self
        filterView = BeautyFiltersView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kFunctionViewHeight), viewModel: BeautyFiltersViewModel(filters: viewModel.beautyFilters, index: viewModel.selectedFilter.index))
        filterView.delegate = self
        
        addSubview(categoriesView)
        categoriesView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(HeightIncludeBottomSafeArea(height: 49))
        }
        
        insertSubview(skinView, belowSubview: categoriesView)
        skinView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(categoriesView.snp_top).offset(kFunctionViewHeight)
            make.height.equalTo(kFunctionViewHeight)
        }
        skinView.isHidden = true
        
        insertSubview(shapeView, belowSubview: categoriesView)
        shapeView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(categoriesView.snp_top).offset(kFunctionViewHeight)
            make.height.equalTo(kFunctionViewHeight)
        }
        shapeView.isHidden = true
        
        insertSubview(filterView, belowSubview: categoriesView)
        filterView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(categoriesView.snp_top).offset(kFunctionViewHeight)
            make.height.equalTo(kFunctionViewHeight)
        }
        filterView.isHidden = true
        
        addSubview(captureButton)
        captureButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 70, height: 70))
            make.bottom.equalTo(categoriesView.snp_top).offset(-15)
        }
        
        addSubview(compareButton)
        compareButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalTo(captureButton.snp_bottom)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
    // MARK: Event response
    
    @objc private func compareTouchDownAction() {
        viewModel.isRendering = false
    }
    
    @objc private func compareTouchUpAction() {
        viewModel.isRendering = true
    }
    
    /// 重载点击背景方法
    func onRenderViewTapAction(sender: UITapGestureRecognizer) {
        // 隐藏视图
        if categoriesView.categoriesViewModel.selectedCategory != .none {
            categoriesView.collectionView(categoriesView.categoriesCollectionView, didSelectItemAt: IndexPath(item: categoriesView.categoriesViewModel.selectedCategory.rawValue, section: 0))
        }
    }
}

extension BeautyView: BeautyCategoriesViewDelegate, BeautyFiltersViewDelegate, BeautySkinViewDelegate {
    // MARK: BeautyCategoriesViewDelegate
    
    func beautyCategoriesViewDidChangeCategory(newCategory: BeautyCategory, oldCategory: BeautyCategory) {
        if oldCategory == .none {
            // 直接显示新的视图
            showView(category: newCategory, animated: true)
            compareButton.isHidden = false
        } else if newCategory == .none {
            // 直接隐藏当前视图
            hideView(category: oldCategory, animated: true)
            compareButton.isHidden = true
        } else {
            // 先隐藏旧的视图
            hideView(category: oldCategory, animated: false)
            // 再显示新的视图
            showView(category: newCategory, animated: true)
        }
    }
    
    // MARK: BeautyParametersViewDelegate
    
    func beautyParametersView(view: BeautySkinView, changedSliderValueAt index: Int) {
        if view == skinView {
            let skin = view.parametersViewModel.beautyParameters[index]
            viewModel.setSkin(value: skin.currentValue, key: BeautySkin(rawValue: skin.type)!)
        } else {
            let shape = view.parametersViewModel.beautyParameters[index]
            viewModel.setShape(value: shape.currentValue, key: BeautyShape(rawValue: shape.type)!)
        }
    }
    
    func beautyParametersViewDidSetDefaultValue(view: BeautySkinView) {
        if view == skinView {
            for skin in view.parametersViewModel.beautyParameters {
                viewModel.setSkin(value: skin.currentValue, key: BeautySkin(rawValue: skin.type)!)
            }
        } else {
            for shape in view.parametersViewModel.beautyParameters {
                viewModel.setShape(value: shape.currentValue, key: BeautyShape(rawValue: shape.type)!)
            }
        }
    }
    
    // MARK: BeautyFiltersViewDelegate
    
    func beautyFiltersView(view: BeautyFiltersView, didSelectAt index: Int) {
        let filter = view.filtersViewModel.beautyFilters[index]
        viewModel.selectedFilter = filter
        viewModel.setFilter(value: filter.value, name: filter.name)
        
        let toast = NSLocalizedString(filter.name, tableName: "Beauty", bundle: .main, value: "", comment: "")
        AutoDismissToast.showType1(toast)
    }
    
    func beautyFiltersView(view: BeautyFiltersView, changedSliderValueAt index: Int) {
        let filter = view.filtersViewModel.beautyFilters[index]
        viewModel.setFilter(value: filter.value, name: filter.name)
    }
}

// MARK: Animation

extension BeautyView {
    func updateCaptureButtonBottomConstraint(constraint: CGFloat, animated: Bool = true) {
        captureButton.snp.updateConstraints { make in
            make.bottom.equalTo(categoriesView.snp_top).offset(-constraint)
        }
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            } completion: { complet in
                if complet {
                    // 更新 self 高度
                    self.snp.updateConstraints { make in
                        make.height.equalTo(49 + constraint + 70 + 30)
                    }
                }
            }
        } else {
            // 更新 self 高度
            snp.updateConstraints { make in
                make.height.equalTo(49 + constraint + 70 + 30)
            }
        }
    }
    
    private func showView(category: BeautyCategory, animated: Bool) {
        updateCaptureButtonBottomConstraint(constraint: kFunctionViewHeight + 10, animated: true)

        switch category {
        case .skin:
            showFunctionView(functionView: skinView, animated: animated)
        case .shape:
            showFunctionView(functionView: shapeView, animated: animated)
        case .filter:
            showFunctionView(functionView: filterView, animated: animated)
        case .none:
            break
        }
    }
    
    private func hideView(category: BeautyCategory, animated: Bool) {
        updateCaptureButtonBottomConstraint(constraint: 15, animated: true)
        switch category {
        case .skin:
            hideFunctionView(functionView: skinView, animated: animated)
        case .shape:
            hideFunctionView(functionView: shapeView, animated: animated)
        case .filter:
            hideFunctionView(functionView: filterView, animated: animated)
        case .none:
            break
        }
    }
    
    private func showFunctionView(functionView: UIView, animated: Bool) {
        functionView.isHidden = false
        if animated {
            functionView.snp.updateConstraints { make in
                make.bottom.equalTo(categoriesView.snp_top)
            }
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
                self.layoutIfNeeded()
            } completion: { _ in
            }
        } else {
            functionView.snp.updateConstraints { make in
                make.bottom.equalTo(categoriesView.snp_top)
            }
        }
    }
    
    private func hideFunctionView(functionView: UIView, animated: Bool) {
        if animated {
            functionView.snp.updateConstraints { make in
                make.bottom.equalTo(categoriesView.snp_top).offset(kFunctionViewHeight)
            }
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
                self.layoutIfNeeded()
            } completion: { _ in
                functionView.isHidden = true
            }

        } else {
            functionView.snp.updateConstraints { make in
                make.bottom.equalTo(categoriesView.snp_top).offset(kFunctionViewHeight)
            }
            functionView.isHidden = true
        }
    }
}
