//
//  HomepageHeaderReusableView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/8.
//

import UIKit
import SnapKit

class HomepageHeaderReusableView: UICollectionReusableView {
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 渐变效果
        let y = (frame.height - 13)/2.0
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 20, y: y, width: 4, height: 13)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor(red: 246/255.0, green: 97/255.0, blue: 255/255.0, alpha: 1.0).cgColor, UIColor(red: 246/255.0, green: 97/255.0, blue: 255/255.0, alpha: 1.0).cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.cornerRadius = 2.0
        layer.addSublayer(gradientLayer)
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.snp_leading).offset(32)
            make.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
