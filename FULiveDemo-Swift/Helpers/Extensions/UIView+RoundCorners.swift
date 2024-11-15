//
//  UIView+RoundCorners.swift
//  FULiveDemo-Swift
//
//  Created by xiezi on 2024/11/6.
//

import UIKit

// 自定义边框图层
private class BorderLayer: CAShapeLayer {}

extension UIView {
    /// 设置视图的圆角和边框(必须先设置view的大小)
    /// - Parameters:
    ///   - corners: 需要设置圆角的位置
    ///   - radius: 圆角半径
    ///   - borderColor: 边框颜色，为nil则不设置边框
    ///   - lineWidth: 边框宽度
    func setRoundedCorners(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor? = nil, lineWidth: CGFloat = 0) {
        if radius == 0 {
            layer.mask = nil
            layer.sublayers?.forEach { layer in
                if layer is BorderLayer {
                    layer.removeFromSuperlayer()
                }
            }
            return
        }

        let rect = bounds
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        // 创建遮罩层
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = path.cgPath
        layer.mask = maskLayer

        // 如果需要边框，创建边框层
        if let borderColor = borderColor {
            layer.sublayers?.forEach { layer in
                if layer is BorderLayer {
                    layer.removeFromSuperlayer()
                }
            }

            let borderLayer = BorderLayer()
            borderLayer.frame = rect
            borderLayer.path = path.cgPath
            borderLayer.lineWidth = lineWidth
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = borderColor.cgColor
            layer.addSublayer(borderLayer)
        }
    }

    /// 设置视图的圆角(必须先设置view的大小)
    /// - Parameters:
    ///   - corners: 需要设置圆角的位置
    ///   - radius: 圆角半径
    func setRoundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
        setRoundedCorners(corners, radius: radius, borderColor: nil, lineWidth: 0)
    }
}

extension CALayer {
    /// 设置图层的圆角
    /// - Parameters:
    ///   - corners: 需要设置圆角的位置
    ///   - radius: 圆角半径
    func setRoundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        mask = maskLayer
    }
}
