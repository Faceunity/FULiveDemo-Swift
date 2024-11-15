#  快速集成文档

## 导入SDK 
### 通过cocoapods集成

```
pod 'FURenderKit', '8.12.0' 
```

接下来执行：

```
pod install
```

如果提示无法找到该版本，请尝试执行以下指令后再试：

```
pod repo update 或 pod setup
```

FURenderKit.framework是动态库，需要在General->Framworks，Libraries,and Embedded  Content 中添加依赖关系，并将Embed设置为Embed&Sign，否则会导致运行后因找不到库而崩溃

## 初始化

```Swift
let config = FUSetupConfig()
let authData: UnsafeMutablePointer<CChar> = transform(&g_auth_package)
let size = MemoryLayout.size(ofValue: g_auth_package)
config.authPack = FUAuthPackMake(authData, Int32(size))
FURenderKit.setup(with: config)
```

## 加载AI模型

```Swift
// 加载人脸AI模型
let faceAIPath = Bundle.main.path(forResource: "ai_face_processor", ofType: "bundle")
FUAIKit.loadAIMode(withAIType: FUAITYPE_FACEPROCESSOR, dataPath: faceAIPath!)

// 加载手势AI模型
let handAIPath = Bundle.main.path(forResource: "ai_hand_processor", ofType: "bundle")
FUAIKit.loadAIMode(withAIType: FUAITYPE_HANDGESTURE, dataPath: handAIPath!)
```

## 设置显示View

FURenderKit 提供了显示渲染结果的 FUGLDisplayView 类（如果使用自定义渲染可忽略本步骤），用户可直接在外部初始化一个 FUGLDisplayView 实例，并赋值给 FURenderKit 单例。FURenderKit 会将渲染结果直接绘制到该 FUGLDisplayView 实例。示例代码如下：

```Swift
// set glDisplayView
lazy var renderView: FUGLDisplayView = {
    let displayView = FUGLDisplayView(frame: .zero)
    let tap = UITapGestureRecognizer(target: self, action: #selector(renderViewTapAction(sender:)))
    displayView.addGestureRecognizer(tap)
    return displayView
}()
FURenderKit.share().glDisplayView = renderView
```

用户也可以不将 FUGLDisplayView 实例赋值给 FURenderKit 单例，直接在外部使用 FUGLDisplayView 的相关接口显示图像。

## 内部相机

FURenderKit 提供了采集图像的 FUCaptureCamera 类（如果使用外部相机可忽略本步骤），用户可直接掉用下面的函数开启或关闭内部相机功能。

```Swift
// 开启内部相机
FURenderKit.share().startInternalCamera()

// 关闭内部相机
FURenderKit.share().stopInternalCamera()
```

**FURenderKit 单例有一个 internalCameraSetting 实例，启动内部相机时会根据 internalCameraSetting 的参数配置相机，internalCameraSetting 具体属性及默认值如下，用户可以通过修改这些参数直接修改相机的相关属性：**

```
@interface FUInternalCameraSetting : NSObject
@property (nonatomic, assign) int format; //default kCVPixelFormatType_32BGRA
@property (nonatomic, copy)  AVCaptureSessionPreset sessionPreset; // default AVCaptureSessionPreset1280x720
@property (nonatomic, assign) AVCaptureDevicePosition position; // default AVCaptureDevicePositionFront
@property (nonatomic, assign) int fps; // default 30
// default NO, 需要注意的是，在打开内部虚拟相机时，用户如果使用Scene相关需要真实相机的功能，内部会自动开启真实相机，并且当用户关闭相关Scene功能时，内部会自动关闭。
@property (nonatomic, assign) BOOL useVirtualCamera; 

/// 如果使用内部相机时，SDK会自动判断当前是否需要使用系统相机，如果不需相机，内部会模拟一个相机并循环输出图像。
/// 该属性可以设置输出图像的宽高，默认宽高为：720x1280，如果设置为CGSizeZero,则会使用 sessionPreset 的宽高。
@property (nonatomic, assign) CGSize virtualCameraResolution;
@end
```

**用户也可以直接使用 FUCaptureCamera 在外部初始化相机实例，并通过 FUCaptureCamera 相关接口获取图像，再将图像传入 FURenderKit 的渲染接口处理图像。 **



## FURenderKit 主要接口说明:

### 渲染接口

#### 1. 输入

FURenderKit 定义了 FURenderInput 类作为输入，该类的具体定义如下：

```
@interface FURenderInput : NSObject

/// 输入的纹理
@property (nonatomic, assign) FUTexture texture;

/// 输入的 pixelBuffer
@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;

/// 输入的 imageBuffer，如果同时传入了 pixelBuffer，将优先使用 pixelBuffer
/// 输入 imageBuffer，在 renderConfig 的 onlyOutputTexture 为 NO 时，render 结果会直接读会输入的 imageBuffer，大小格式与输入均保持一致。
@property (nonatomic, assign) FUImageBuffer imageBuffer;

/// 设置render相关的输入输出配置，详细参数请查看 FURenderConfig 类的接口注释。
@property (nonatomic, strong) FURenderConfig *renderConfig;

@end
```

用户可以根据自己代码中的数据，选择输入一种或多种格式的图像，如果传入多种格式时，如果同时传入了 pixelBuffer 和 imageBuffer，会优先使用 pixelBuffer 进行图像处理。FUTexture 及 FUImageBuffer相关属性，请查看相关头文件。

### 2. 配置

FURenderInput 中有一个 FURenderConfig 类，该类用来配置一些输入及输出的相关设置，具体定义如下：

```
@interface FURenderConfig : NSObject

// 自定义输出结果的大小，当前只会对输出的纹理及pixelBuffer有效
@property (nonatomic, assign) CGSize customOutputSize;

// 当前图片是否来源于前置摄像头
@property (nonatomic, assign) BOOL isFromFrontCamera;

// 原始图像的朝向
@property (nonatomic, assign) FUImageOrientation imageOrientation;

// 重力开关，开启此功能可以根据已设置的 imageRotation 自动适配AI检测的方向。
@property (nonatomic, assign) BOOL gravityEnable;

// 设置为YES 只会生效美颜结果
@property (nonatomic, assign) BOOL onlyRenderBeauty;

// 设置输入纹理的旋转方向，设置该属性会影响输出纹理的方向。由于默认创建的纹理是倒着的，所以该参数的默认值为 CCROT0_FLIPVERTICAL，如已转正，请将该参数设置为 DEFAULT
@property (nonatomic, assign) TRANSFORM_MATRIX textureTransform;

// 设置输入pixelBuffer/imageBuffer的旋转方向，以使buffer数据与textureTransform作用后纹理的方向一致，该参数仅用于AI算法检测，不会改变buffer的方向或镜像属性
@property (nonatomic, assign) TRANSFORM_MATRIX bufferTransform;

// 是否渲染到当前的FBO，设置为YES时，返回的 FURenderOutput 内的所有数据均为空值。
@property (nonatomic, assign) BOOL renderToCurrentFBO;

// 设置为YES 且 renderToCurrentFBO 为 NO 时，只会输出纹理，不会输出CPU层的图像。
@property (nonatomic, assign) BOOL onlyOutputTexture;

@end
  
```

### 3. 输出

FURenderKit 定义了 FURenderOutput 类作为输出，该类的具体定义如下： 输出的图像类型及个数与输入相同。

```
@interface FURenderOutput : NSObject

// 设置输入纹理的旋转方向，设置该属性会影响输出纹理的方向。由于默认创建的纹理是倒着的，所以该参数的默认值为 CCROT0_FLIPVERTICAL，如已转正，请将该参数设置为 DEFAULT
@property (nonatomic, assign) TRANSFORM_MATRIX textureTransform;

// 设置输入pixelBuffer/imageBuffer的旋转方向，以使buffer数据与textureTransform作用后纹理的方向一致，该参数仅用于AI算法检测，不会改变buffer的方向或镜像属性
@property (nonatomic, assign) TRANSFORM_MATRIX bufferTransform;

// 设置输入pixelBuffer/imageBuffer的旋转方向，以使buffer数据与textureTransform作用后纹理的方向一致，该参数仅用于AI算法检测，不会改变buffer的方向或镜像属性
@property (nonatomic, assign) TRANSFORM_MATRIX outputTransform;

// 输出的纹理
@property (nonatomic, assign) FUTexture texture;

// 输出的 pixelBuffer
@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;

// 输出的 imageBuffer，内部数据与输入的 imageBuffer 一致。
@property (nonatomic, assign) FUImageBuffer imageBuffer;

@end
```



### 内部渲染回调

FURenderKit 定义了一个 FURenderKitDelegate 协议，该协议包含三个接口，一个是使用内部相机时即将处理图像时输入回调，另一个是使用内部相机时处理图像后的输出回调

```
// 使用内部相机时，即将处理图像时输入
- (void)renderKitWillRenderFromRenderInput:(FURenderInput *)renderInput;

// 使用内部相机时，处理图像后的输出
- (void)renderKitDidRenderToOutput:(FURenderOutput *)renderOutput;

// 使用内部相机时，内部是否进行render处理，返回NO，renderKitDidRenderToOutput接口将直接输出原图. YES,renderKitDidRenderToOutput接口输出带渲染道具的图
- (BOOL)renderKitShouldDoRender;
```

### 外部渲染接口

FURenderKit 提供了下面的接口处理图像，用户可以在外部将图像传入该接口获取处理之后的图像。

```
- (FURenderOutput *)renderWithInput:(FURenderInput *)input;
```


## 开启关闭相机

```
#pragma mark - internalCamera

- (void)startInternalCamera;

- (void)stopInternalCamera;
```



## 根据证书校验模块权限

```
/**
 * 获取证书里面的模块权限
 * code get i-th code, currently available for 0 and 1
 */
+ (int)getModuleCode:(int)code;
```



## 销毁

#### 内部会销毁相机、各个的渲染模型（美颜、美妆、道具贴纸等），释放ai资源以及销毁底层相关的资源

```Swift
- (void)destroy
```



## 清除

#### 和destory 区别 只会清除各个的渲染模型（美颜、美妆、道具贴纸等)，其他不处理

```Swift
+ (void)clear;
```



## 录像和拍照

```Swift
#pragma mark - Record && capture
//手指按下录像按钮调用
+ (void)startRecordVideoWithFilePath:(NSString *)filePath;
//手指松开录像按钮调用
+ (void)stopRecordVideoComplention:(void(^)(NSString *filePath))complention;
//捕获当前帧作为图片
+ (UIImage *)captureImage;
```



## FUAIKit

AI能力相关的功能都通过FUAIKit 加载或获取

部分接口和属性介绍

```Swift
@property (nonatomic, assign) int maxTrackFaces; // 设置最大的人脸跟踪个数 default is 1

@property (nonatomic, assign) int maxTrackBodies; // 设置最大的人体跟踪个数 default is 1

@property (nonatomic, assign, readonly) int trackedFacesCount; // 跟踪到的人脸个数

@property (nonatomic, assign) FUFaceProcessorDetectMode faceProcessorDetectMode; // 图像加载模式 default is FUFaceProcessorDetectModeVideo

@property (nonatomic, assign) BOOL asyncTrackFace; //设置是否进行异步人脸跟踪

@property (nonatomic, assign) FUFaceProcessorFaceLandmarkQuality faceProcessorFaceLandmarkQuality;  // 人脸算法质量

//加载 AI bundle
+ (void)loadAIModeWithAIType:(FUAITYPE)type dataPath:(NSString *)dataPath;
//卸载 AI bundle
+ (void)unloadAIModeForAIType:(FUAITYPE)type;
//卸载所有 AI bundle
+ (void)unloadAllAIMode;

+ (BOOL)loadedAIType:(FUAITYPE)type;
//加载舌头驱动
+ (void)loadTongueMode:(NSString *)modePath;
//脸部类型 单独加载
+ (void)setTrackFaceAIType:(FUAITYPE)type;

+ (int)trackFaceWithInput:(FUTrackFaceInput *)trackFaceInput;
// Reset ai model HumanProcessor's tracking state.
+ (void)resetHumanProcessor;
//get ai model HumanProcessor's tracking result.
+ (int)aiHumanProcessorNums;
//人脸检测置信度
+ (float)fuFaceProcessorGetConfidenceScore:(int)index;
```

其他接口参考  FUAIKit.h 



## 功能模块： 功能模块加载的bundle 名称可以自己定义，示例代码名称根据自己定义的名称来加载

### 美颜

#### 初始化美颜

使用 FUBeauty 类初始化美颜实例，并将美颜实例赋值给 FURenderKit 即可, 内部是同步线程串行队列处理，处理会耗时。外部可以自己用线程管理。

```Swift
// 初始化FUBeauty
if let path = Bundle.main.path(forResource: "face_beautification", ofType: "bundle") {
    beauty = FUBeauty(path: path, name: "FUBeauty")
    beauty.heavyBlur = 0
    // 默认均匀磨皮
    beauty.blurType = 3
    // 默认精细变形
    beauty.faceShape = 4
    
    // 高性能设备设置去黑眼圈、去法令纹、大眼、嘴形的最新效果
    let performanceLevel = FURenderKit.devicePerformanceLevel().rawValue
    if performanceLevel >= 2 {
        beauty.add(.mode2, forKey: .removePouchStrength)
        beauty.add(.mode2, forKey: .removeNasolabialFoldsStrength)
        beauty.add(.mode3, forKey: .eyeEnlarging)
        beauty.add(.mode3, forKey: .intensityMouth)
    }
}

```

#### 修改美颜参数

可以直接修改 FUBeauty 的相关属性，也可以初始化一个新的美颜实例，修改好参数后直接赋值给 FURenderKit；修改属性示例如下，属性对应的含义详见FUBeauty.h 注释：

```Swift
beauty.blurUseMask = false
滤镜FileName 对应的value 值FURenderKit 已经做了对应的映射关系，直接调用即可
beauty.filterLevel = 1
beauty.filterName = FUFilterOrigin

beauty.colorLevel = 0.3
beauty.redLevel = 0.3
beauty.blurLevel = 0.7*6
beauty.heavyBlur = 0
beauty.blurType = 3

beauty.sharpen = 0.2
beauty.eyeBright = 0.0
beauty.toothWhiten = 0.0

beauty.removePouchStrength = 0.0
beauty.removeNasolabialFoldsStrength = 0.0

beauty.faceShapeLevel = 1.0
beauty.changeFrames = 0
beauty.faceShape = 4

beauty.eyeEnlarging = 0.4
beauty.cheekThinning = 0.0
beauty.cheekV = 0.5
beauty.cheekNarrow = 0.0
beauty.cheekShort = 0.0
beauty.cheekSmall = 0.0
beauty.intensityNose = 0.5
beauty.intensityForehead = 0.3
beauty.intensityMouth = 0.4
beauty.intensityChin = 0.3
beauty.intensityPhiltrum = 0.5
beauty.intensityLongNose = 0.5
beauty.intensityEyeSpace = 0.5
beauty.intensityEyeRotate = 0.5
beauty.intensitySmile = 0.0
beauty.intensityCanthus = 0.5
beauty.intensityCheekbones = 0
beauty.intensityLowerJaw= 0.0
beauty.intensityEyeCircle = 0.0
```



### 道具贴纸

使用 FUSticker或其子类初始化贴纸实例，FURenderKit 内部提供了一个 FUStickerContainer 类来管理贴纸，只需将贴纸实例添加、替换到 FUStickerContainer 实例即可实现贴纸的显示，然后可以掉用 FUStickerContainer 的删除接口移除贴纸效果。示例如下：

```swift
// 添加
let path = Bundle.main.path(forResource: items[index].id, ofType: "bundle")!
let sticker = FUSticker(path: path, name: "FUSticker")
FURenderKit.share().stickerContainer.add(sticker) {
    // 成功后回调
}

// 替换
FURenderKit.share().stickerContainer.replace(currentSticker!, with: sticker) {
    // 成功后回调
}
// 移除
FURenderKit.share().stickerContainer.removeAllSticks()

```



### 手势识别

是一种带有其他属性的贴纸

```swift
let itemId = items[index].id
let path = Bundle.main.path(forResource: itemId, ofType: "bundle")!
let gesture = FUGesture(path: path, name: "FUGesture")
if itemId == "ssd_thread_korheart" {
    gesture.handOffY = -100  //可以单独调整比心的偏移量，> 0 向上，< 0 向下
}
```





