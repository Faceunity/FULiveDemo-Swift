//
//  SquareButton.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/15.
//

import UIKit

class SquareButton: UIButton {
    
    private var spacing: CGFloat = 0

    init(frame: CGRect, spacing: CGFloat) {
        super.init(frame: frame)
        self.spacing = spacing
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageBounds = imageView?.bounds
        var labelFrame = titleLabel?.frame
        
        imageView?.frame = imageBounds!
        var imageCenter = imageView?.center
        imageCenter?.x = frame.size.width * 0.5
        imageView?.center = imageCenter!
        
        labelFrame?.origin.x = 0
        labelFrame?.origin.y = (imageView?.frame.maxY)! + spacing
        labelFrame?.size.height = 11
        labelFrame?.size.width = bounds.size.width
        titleLabel?.frame = labelFrame!
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
