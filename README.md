# FUTouchID
- 一行代码解决指纹解锁


### CocoaPods

1. Add `pod 'FUTouchID', '~> 1.0.0'` to your Podfile.

2. Run `pod install` or `pod update`.

3. '#import "FUTouchID.h"'.


### 登录时
##### *第一次的登录弹框提示是否使用指纹解锁
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/1.png" width="30%" height="30%">
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/2.png" width="30%" height="30%">

##### *设置中关闭了TouchID，再次打开app
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/7.png" width="30%" height="30%">

### 指纹验证错误
##### *输入错误一次
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/4.png" width="30%" height="30%">

##### *输入错误三次
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/5.png" width="30%" height="30%">

##### *输入错误五次
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/6.png" width="30%" height="30%">

##### *输入错误五次，验证密码后，继续弹框验证指纹
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/2.png" width="30%" height="30%">


### 指纹解锁开关
##### *弹出指纹验证界面
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/12.jpeg" width="30%" height="30%">

##### *指纹验证成功
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/8.png" width="30%" height="30%">

##### *设置中关闭了TouchID，指纹验证失败
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUTouchID/9.png" width="30%" height="30%">

提供的方法
==============
### 判断设备指纹识别功能【是否可用】 
```
/*
* 判断设备指纹识别功能【是否可用】
*/
+ (BOOL)canEvaluatePolicy;
```
### 判断设备指纹识别功能【是否支持】
```
/*
* 判断设备指纹识别功能【是否支持】
*/
+ (BOOL)canPlatformSupportTouchID;
```

### 指纹登录验证
```
/*
* 指纹登录验证
*
* clickBlock 按钮的点击事件
*/
+ (void)loadAuthenticationWithTouchBlock:(TouchBlock)clickBlock;
```

### 弹框提示是否使用指纹解锁
```
/*
* 弹框提示是否使用指纹解锁
*
* clickBlock 按钮的点击事件
*/
+ (void)showTouchIDAlertView:(TouchBlock)clickBlock;

```




许可证
==============
LEETheme 使用 GPL V3 许可证，详情见 LICENSE 文件。

