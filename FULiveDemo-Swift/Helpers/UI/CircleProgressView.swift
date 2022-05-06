//
//  CircleProgressView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/21.
//

import UIKit

class CircleProgressView: UIView {
    
    var percent: CGFloat! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let progressWidth = 3.0
    
    override init(frame: CGRect) {
        percent = 0.0
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.setShouldAntialias(true)
        if percent > 0 {
            let angle = percent * 2 * CGFloat.pi - CGFloat.pi/2
            context.addArc(center: CGPoint(x: frame.width/2.0, y: frame.height/2.0), radius: (frame.width - progressWidth)/2.0, startAngle: -(.pi/2), endAngle: angle, clockwise: false)
            // 设置描边颜色
            UIColor(red: 92/255.0, green: 181/255.0, blue: 249/255.0, alpha: 1.0).setStroke()
            context.setLineWidth(progressWidth)
            context.strokePath()
        }
    }
}
