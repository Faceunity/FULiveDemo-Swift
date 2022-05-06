//
//  InsetsLabel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/19.
//

import UIKit

class InsetsLabel: UILabel {
    
    var insets: UIEdgeInsets!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    init(frame: CGRect, insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)) {
        super.init(frame: frame)
        
        self.insets = insets
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var fitSize = super.sizeThatFits(size)
        fitSize.width += insets.left + insets.right
        fitSize.height += insets.top + insets.bottom
        return fitSize
    }
}
