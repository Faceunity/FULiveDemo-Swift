//
//  HomepageNavigationView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/12.
//

import UIKit

class HomepageNavigationView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(hex: "030010")
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("FULiveDemo", comment: "")
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hex: "302D33")
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
