//
//  HomepageCollectionViewCell.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/6.
//

import UIKit
import SnapKit

class HomepageCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var bottomImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var textLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "1F1D35")
        layer.masksToBounds = true
        layer.cornerRadius = 5.0
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-14)
            make.size.equalTo(CGSize(width: 47, height: 40))
        }
        
        contentView.addSubview(bottomImageView)
        bottomImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(bottomImageView.snp_height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
