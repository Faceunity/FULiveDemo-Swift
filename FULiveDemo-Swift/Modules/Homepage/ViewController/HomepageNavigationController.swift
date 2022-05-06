//
//  HomepageNavigationController.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/6.
//

import UIKit

class HomepageNavigationController: UINavigationController {
    
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarHidden(true, animated: false)
    }
    

}
