//
//  SegmentedControl.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/6.
//

import UIKit

class SegmentedControl: UIView {
    // MARK: - Properties

    private var labels: [UILabel] = []
    private var labelWidths: [CGFloat] = []
    private let horizontalPadding: CGFloat = 5 // label 左右内边距
    private let minimumItemWidth: CGFloat = 20 // 最小宽度
        
    var shouldSelectItem: ((Int) -> Bool)!
    var didSelectItem: ((Int) -> Void)!
        
    var items: [String] = [] {
        didSet {
            setupLabels()
        }
    }
        
    var selectedIndex: Int = 0 {
        didSet {
            updateSelection()
        }
    }
        
    var titleColor: UIColor = .white {
        didSet {
            labels.forEach { $0.textColor = titleColor }
        }
    }
        
    var selectedTitleColor: UIColor = .black {
        didSet {
            updateSelection()
        }
    }
        
    var titleFont: UIFont = .systemFont(ofSize: 11, weight: .medium) {
        didSet {
            labels.forEach { $0.font = titleFont }
            calculateLabelWidths()
            setNeedsLayout()
        }
    }
        
    // MARK: - Initialization

    init(frame: CGRect, items: [String]) {
        super.init(frame: frame)
        clipsToBounds = true
        self.items = items
        setupUI()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
        
    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
            
        // 先设置圆角等属性，确保在布局之前就应用
        setRoundedCorners(UIRectCorner.allCorners, radius: bounds.height / 2.0, borderColor: .white, lineWidth: 2)
            
        var currentX: CGFloat = 0
        let height = bounds.height
        let totalWidth = labelWidths.reduce(0, +)
            
        // 确保总宽度正好等于控件宽度，避免因宽度计算误差导致的圆角显示问题
        let scale = bounds.width / totalWidth
            
        for (index, label) in labels.enumerated() {
            let scaledWidth = labelWidths[index] * scale
            label.frame = CGRect(x: currentX,
                                 y: 0,
                                 width: scaledWidth,
                                 height: height)
            currentX += scaledWidth
        }
    }
        
    // MARK: - Private Methods

    private func setupUI() {
        backgroundColor = .black
        setupLabels()
    }
        
    private func calculateLabelWidths() {
        labelWidths.removeAll()
            
        for (index, _) in labels.enumerated() {
            let text = items[index]
            var width = (text as NSString).size(withAttributes: [.font: titleFont]).width
            width += horizontalPadding * 2 // 添加左右内边距
            width = max(width, minimumItemWidth) // 确保不小于最小宽度
            labelWidths.append(width)
        }
    }
        
    private func setupLabels() {
        // 清除现有的 labels
        labels.forEach { $0.removeFromSuperview() }
        labels.removeAll()
        labelWidths.removeAll()
            
        // 创建新的 labels
        for (index, item) in items.enumerated() {
            let label = createLabel(with: item)
            label.tag = index
            labels.append(label)
            addSubview(label)
                
            let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
            label.addGestureRecognizer(tap)
        }
            
        calculateLabelWidths()
        setNeedsLayout()
        updateSelection()
    }
        
    private func createLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = titleFont
        label.textColor = titleColor
        label.isUserInteractionEnabled = true
        return label
    }
        
    private func updateSelection() {
        for (index, label) in labels.enumerated() {
            if index == selectedIndex {
                label.textColor = selectedTitleColor
                label.backgroundColor = .white
            } else {
                label.textColor = titleColor
                label.backgroundColor = .clear
            }
        }
    }
        
    @objc private func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        let index = label.tag
            
        if index == selectedIndex { return }
            
        if let shouldSelect = shouldSelectItem {
            guard shouldSelect(index) else { return }
        }
            
        selectedIndex = index
        didSelectItem(index)
    }
        
    // MARK: - Public Methods

    func refreshUI() {
        calculateLabelWidths()
        setNeedsLayout()
        updateSelection()
    }
}
