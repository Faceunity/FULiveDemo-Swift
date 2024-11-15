//
//  LiveSlider.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/14.
//

import UIKit

class LiveSlider: UISlider {
    
    private lazy var tipBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "slider_tip_bg") {
            imageView.image = image
            imageView.frame = CGRect(x: 0, y: -image.size.height, width: image.size.width, height: image.size.height)
        }
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var tipLabel: UILabel = {
        let label = UILabel(frame: tipBackgroundImageView.frame)
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.isHidden = true
        return label
    }()
    
    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(redValue: 94, greenValue: 199, blueValue: 254)
        view.isHidden = true
        return view
    }()
    
    private lazy var middleLine: UIView = {
        let view = UIView(frame: CGRect(x: bounds.width/2.0 - 1.0, y: bounds.height/2.0 - 4.0, width: 2.0, height: 8.0))
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 1.0
        return view
    }()
    
    /// 默认值是否在中间
    var defaultValueInMiddle: Bool {
        didSet {
            if defaultValueInMiddle {
                middleLine.isHidden = false
                trackView.isHidden = false
                minimumTrackTintColor = .white
            } else {
                middleLine.isHidden = true
                trackView.isHidden = true
                minimumTrackTintColor = UIColor(redValue: 94, greenValue: 199, blueValue: 254)
            }
        }
    }
    
    override init(frame: CGRect) {
        defaultValueInMiddle = false
        
        super.init(frame: frame)
        
        setThumbImage(UIImage(named: "slider_dot"), for: .normal)
        maximumTrackTintColor = .white
        minimumTrackTintColor = UIColor(redValue: 94, greenValue: 199, blueValue: 254)
        
        addSubview(tipBackgroundImageView)
        addSubview(tipLabel)
        addSubview(trackView)
        addSubview(middleLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        middleLine.frame = CGRect(x: bounds.width/2.0 - 1.0, y: bounds.height/2.0 - 4.0, width: 2.0, height: 8.0)
        self.setValue(value, animated: false)
    }
    
    override func setValue(_ value: Float, animated: Bool) {
        super.setValue(value, animated: animated)
        
        if defaultValueInMiddle {
            let displayValue = (value * 100).rounded() - 50
            tipLabel.text = String(format: "%.f", displayValue)
            let currentValue = CGFloat(value - 0.5)
            var width = currentValue * bounds.width
            if width < 0 {
                width = -width
            }
            let x = currentValue > 0 ? (bounds.width/2.0) : (bounds.width/2.0 - width)
            trackView.frame = CGRect(x: x, y: bounds.height/2.0 - 2, width: width, height: 4)
        } else {
            tipLabel.text = String(format: "%.f", value * 100)
        }
        
        var frame = tipLabel.frame
        let x = CGFloat(value) * (bounds.width - 20) - frame.size.width * 0.5 + 10
        frame.origin.x = x;
        
        tipBackgroundImageView.frame = frame
        tipLabel.frame = frame
        tipBackgroundImageView.isHidden = !isTracking
        tipLabel.isHidden = !isTracking
    }
    
}
