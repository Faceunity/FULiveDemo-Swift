//
//  BeautyViewController.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/12.
//

import UIKit
import FURenderKit
import CoreMIDI

class BeautyViewController: BaseViewController<BeautyViewModel> {
    
    private let categoryCellIdentifer = "BeautyCategoryCell"
    
    /// 底部功能分类视图
    lazy var categoriesView: BeautyCategoriesView = {
        let view = BeautyCategoriesView(frame: .zero, viewModel: BeautyCategoriesViewModel())
        view.delegate = self
        return view
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
    var skinView: BeautyParametersView!
    
    /// 美型视图
    var shapeView: BeautyParametersView!
    
    /// 滤镜视图
    var filterView: BeautyFiltersView!
    
    /// 风格推荐视图
    var stylesView: BeautyStylesView!
     
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loadItem()
        configureBeautyUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 加载美颜缓存
        viewModel.reloadBeautyParams()
        
        // 加载美颜缓存之后需要更新UI
        skinView.reloadSubviews(params: viewModel.beautySkinParams)
        shapeView.reloadSubviews(params: viewModel.beautyShapeParams)
        if viewModel.selectedFilter != nil {
            filterView.selectFilter(filter: viewModel.selectedFilter)
        }
        
        if viewModel.selectedStyle.index > 0 {
            // 选中风格推荐时，自动切换分类选择
            categoriesView.selectCategory(category: .preset)
            categoriesView.styleSelected = true
            updateCaptureButtonBottomConstraint(constraint: 158)
        }

        if viewModel.selectedStyle.index != stylesView.stylesViewModel.selectedIndex {
            stylesView.selectStyle(index: self.viewModel.selectedStyle.index)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 更新美颜缓存
        viewModel.cacheBeautyParams()
        viewModel.releaseItem()
    }
    
    //MARK: UI
    
    private func configureBeautyUI() {
        
        skinView = BeautyParametersView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 146), viewModel: BeautyParametersViewModel(parameters: viewModel.beautySkinParams))
        skinView.delegate = self
        shapeView = BeautyParametersView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 146), viewModel: BeautyParametersViewModel(parameters: viewModel.beautyShapeParams))
        shapeView.delegate = self
        filterView = BeautyFiltersView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 146), viewModel: BeautyFiltersViewModel(filters: viewModel.beautyFilters, index: viewModel.selectedFilter.index))
        filterView.delegate = self
        stylesView = BeautyStylesView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 98), viewModel: BeautyStylesViewModel(styles: viewModel.beautyStyles, index: viewModel.selectedStyle.index))
        stylesView.delegate = self
        
        view.addSubview(categoriesView)
        categoriesView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(HeightIncludeBottomSafeArea(height: 49))
        }
        
        view.insertSubview(skinView, belowSubview: categoriesView)
        skinView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(categoriesView.snp_top).offset(146)
            make.height.equalTo(146)
        }
        skinView.isHidden = true
        
        view.insertSubview(shapeView, belowSubview: categoriesView)
        shapeView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(categoriesView.snp_top).offset(146)
            make.height.equalTo(146)
        }
        shapeView.isHidden = true
        
        view.insertSubview(filterView, belowSubview: categoriesView)
        filterView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(categoriesView.snp_top).offset(146)
            make.height.equalTo(146)
        }
        filterView.isHidden = true
        
        view.insertSubview(stylesView, belowSubview: categoriesView)
        stylesView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(categoriesView.snp_top).offset(146)
            make.height.equalTo(98)
        }
        stylesView.isHidden = true
        
        view.addSubview(compareButton)
        compareButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalTo(categoriesView.snp_top).offset(-156)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
    //MARK: Event response
    
    @objc private func compareTouchDownAction() {
        viewModel.isRendering = false
    }
    
    @objc private func compareTouchUpAction() {
        viewModel.isRendering = true
    }
    
    /// 重载点击背景方法
    override func renderViewTapAction(sender: UITapGestureRecognizer) {
        super.renderViewTapAction(sender: sender)
        
        // 隐藏视图
        if categoriesView.categoriesViewModel.selectedCategory != .none {
            categoriesView.collectionView(categoriesView.categoriesCollectionView, didSelectItemAt: IndexPath(item: categoriesView.categoriesViewModel.selectedCategory.rawValue, section: 0))
        }
    }
    
    //MARK: PopMenuDelegate
    
    override func popMenuDidClickSelectingMedia() {
        let selectMediaController = SelectMediaViewController()
        navigationController?.pushViewController(selectMediaController, animated: true)
    }
    
}

extension BeautyViewController: BeautyCategoriesViewDelegate, BeautyFiltersViewDelegate, BeautyParametersViewDelegate, BeautyStylesViewDelegate {
    
    //MARK: BeautyCategoriesViewDelegate
    
    func beautyCategoriesViewDidChangeCategory(newCategory: BeautyCategory, oldCategory: BeautyCategory) {
        if oldCategory == .none {
            // 直接显示新的视图
            showView(category: newCategory, animated: true)
            compareButton.isHidden = false
        } else if newCategory == .none {
            // 直接隐藏当前视图
            hideView(category: oldCategory, animated: true)
            compareButton.isHidden = true
        }  else {
            // 先隐藏旧的视图
            hideView(category: oldCategory, animated: false)
            // 再显示新的视图
            showView(category: newCategory, animated: true)
        }
    }
    
    //MARK: BeautyParametersViewDelegate
    
    func beautyParametersView(view: BeautyParametersView, changedSliderValueAt index: Int) {
        if view == skinView {
            let skin = view.parametersViewModel.beautyParameters[index]
            viewModel.setSkin(value: skin.currentValue, key: BeautySkin(rawValue: skin.type)!)
        } else {
            let shape = view.parametersViewModel.beautyParameters[index]
            viewModel.setShape(value: shape.currentValue, key: BeautyShape(rawValue: shape.type)!)
        }
    }
    
    func beautyParametersViewDidSetDefaultValue(view: BeautyParametersView) {
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
    
    //MARK: BeautyFiltersViewDelegate
    
    func beautyFiltersView(view: BeautyFiltersView, didSelectAt index: Int) {
        let filter = view.filtersViewModel.beautyFilters[index]
        viewModel.selectedFilter = filter
        viewModel.setFilter(value: filter.value, name: filter.name)
    }
    
    func beautyFiltersView(view: BeautyFiltersView, changedSliderValueAt index: Int) {
        let filter = view.filtersViewModel.beautyFilters[index]
        viewModel.setFilter(value: filter.value, name: filter.name)
    }
    
    //MARK: BeautyStyleViewDelegate
    
    func beautyStyleView(view: BeautyStylesView, didSelectAt index: Int) {
        let style = view.stylesViewModel.beautyStyles[index]
        viewModel.selectedStyle = style
        if index == 0 {
            // 取消风格推荐，重新设置当前美颜
            let filter = filterView.filtersViewModel.beautyFilters[filterView.filtersViewModel.selectedIndex]
            viewModel.setFilter(value: filter.value, name: filter.name)
            for skin in skinView.parametersViewModel.beautyParameters {
                viewModel.setSkin(value: skin.currentValue, key: BeautySkin(rawValue: skin.type)!)
            }
            for shape in shapeView.parametersViewModel.beautyParameters {
                viewModel.setShape(value: shape.currentValue, key: BeautyShape(rawValue: shape.type)!)
            }
            categoriesView.styleSelected = false
            
        } else {
            // 设置风格推荐
            viewModel.setStyle(style: style)
            categoriesView.styleSelected = true
        }
        
    }
    
}

//MARK: Animation

extension BeautyViewController {
    
    private func showView(category: BeautyCategory, animated: Bool) {
        if category == .preset {
            compareButton.snp.updateConstraints { make in
                make.bottom.equalTo(categoriesView.snp_top).offset(-108)
            }
            updateCaptureButtonBottomConstraint(constraint: 158)
        } else {
            compareButton.snp.updateConstraints { make in
                make.bottom.equalTo(categoriesView.snp_top).offset(-156)
            }
            updateCaptureButtonBottomConstraint(constraint: 206)
        }
        switch category {
        case .skin:
            showFunctionView(functionView: skinView, animated: animated)
        case .shape:
            showFunctionView(functionView: shapeView, animated: animated)
        case .filter:
            showFunctionView(functionView: filterView, animated: animated)
        case .preset:
            showFunctionView(functionView: stylesView, animated: animated)
        case .none:
            break
        }
    }
    
    private func hideView(category: BeautyCategory, animated: Bool) {
        updateCaptureButtonBottomConstraint(constraint: 60)
        switch category {
        case .skin:
            hideFunctionView(functionView: skinView, animated: animated)
        case .shape:
            hideFunctionView(functionView: shapeView, animated: animated)
        case .filter:
            hideFunctionView(functionView: filterView, animated: animated)
        case .preset:
            hideFunctionView(functionView: stylesView, animated: animated)
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
                self.view.layoutIfNeeded()
            } completion: { finished in
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
                make.bottom.equalTo(categoriesView.snp_top).offset(146)
            }
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            } completion: { finished in
                functionView.isHidden = true
            }

        } else {
            functionView.snp.updateConstraints { make in
                make.bottom.equalTo(categoriesView.snp_top).offset(146)
            }
            functionView.isHidden = true
        }
    }
}
