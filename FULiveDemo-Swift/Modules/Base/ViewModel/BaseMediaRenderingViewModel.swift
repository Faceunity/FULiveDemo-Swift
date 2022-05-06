//
//  BaseMediaRenderingViewModel.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/21.
//

import UIKit

enum MediaType {
case image, video
}

enum TrackType {
case face, body
}


class BaseMediaRenderingViewModel: NSObject {
    /// 是否需要渲染
    var isRendering: Bool = true
    
    /// 是否需要检测
    var isNeedTrack: Bool = true
    
    /// 检测类型
    var trackType: TrackType = .face
    
    var mediaType: MediaType!
    
    var image: UIImage?
    
    var videoURL: NSURL?
    
    init(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 1) {
            self.image = UIImage(data: data)
            self.mediaType = .image
        }
        super.init()
    }
    
    init(videoURL: NSURL) {
        self.videoURL = videoURL
        self.mediaType = .video
        super.init()
    }

}
