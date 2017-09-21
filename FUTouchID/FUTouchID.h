//
//  FUTouchID.h
//  YtoCustomService
//
//  Created by FJZ on 2017/9/6.
//  Copyright © 2017年 Jiessie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>
// block 防止循环引用的弱引用
#define WEAKSELF typeof(self) __weak weakSelf = self;
// block 强引用
#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;

typedef NS_ENUM(NSInteger,FUTouchIDState)
{
    FUTouchIDStateReplyLaterBesides = -1,//右侧按钮稍后再说
    FUTouchIDStateReplySuccess = -2,     //验证成功
    FUTouchIDStateReplyFail = -3,        //验证失败
    FUTouchIDStateNotAvailable = -4,     //设备不可用
    FUTouchIDStateNotSupport = -5        //设备不支持
    
};

typedef void(^TouchBlock) (FUTouchIDState touchIDState,LAError error);

@interface FUTouchID : NSObject

/*
 * 判断设备指纹识别功能【是否可用】
 */
+ (BOOL)canEvaluatePolicy;
/*
 * 判断设备指纹识别功能【是否支持】
 */
+ (BOOL)canPlatformSupportTouchID;
/*
 * 指纹登录验证
 *
 * clickBlock 按钮的点击事件
 */
+ (void)loadAuthenticationWithTouchBlock:(TouchBlock)clickBlock;
/*
 * 弹框提示是否使用指纹解锁
 *
 * clickBlock 按钮的点击事件
 */
+ (void)showTouchIDAlertView:(TouchBlock)clickBlock;
@end
