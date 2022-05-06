//
//  LightingView.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/21.
//

import UIKit

typealias LightValueChangedClosure = (_ value: Float) -> Void

class LightingView: UIView {
    
    private lazy var sunImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "lighting_sun"))
        imageView.frame = CGRect(x: frame.size.width - 30, y: 0, width: 20, height: 20)
        return imageView
    }()
    
    private lazy var monImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "lighting_mon"))
        imageView.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        return imageView
    }()
    
    private lazy var lightSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: 40, y: 0, width: frame.size.width - 80, height: 20))
        slider.setThumbImage(UIImage(named: "lighting_thumb"), for: .normal)
        slider.maximumTrackTintColor = .white
        slider.minimumTrackTintColor = .white
        slider.minimumValue = -2
        slider.maximumValue = 2
        slider.value = 0
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        let line = UIView(frame: CGRect(x: slider.frame.size.width/2.0 - 1.0, y: 4, width: 2, height: slider.frame.size.height - 8.0))
        line.backgroundColor = .white
        line.layer.masksToBounds = true
        line.layer.cornerRadius = 1.0
        slider.insertSubview(line, at: slider.subviews.count - 1)
        return slider
    }()
    
    var callBack: LightValueChangedClosure?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    init(frame: CGRect, changedClosure: @escaping LightValueChangedClosure) {
        self.callBack = changedClosure
        super.init(frame: frame)
        
        configureUI()
    }
    
    private func configureUI() {
        addSubview(monImageView)
        addSubview(sunImageView)
        addSubview(lightSlider)
        
        sunImageView.transform = CGAffineTransform(rotationAngle: .pi/2)
        monImageView.transform = CGAffineTransform(rotationAngle: .pi/2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func sliderValueChanged() {
        if let closure = callBack {
            closure(lightSlider.value)
        }
    }
    
}
