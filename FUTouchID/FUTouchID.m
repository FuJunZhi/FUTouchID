//
//  FUTouchID.m
//  YtoCustomService
//
//  Created by FJZ on 2017/9/6.
//  Copyright © 2017年 Jiessie. All rights reserved.
//

#import "FUTouchID.h"
#include <sys/sysctl.h>
#import <UIKit/UIKit.h>
#define kFUTouchID [FUTouchID shareTool]
#define IOS8_OR_LATER    ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
#define IS_Phone UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone

@implementation FUTouchID

/**
 * 指纹登录验证
LAPolicyDeviceOwnerAuthenticationWithBiometrics 用的是手指指纹去验证的；iOS8 可用
LAPolicyDeviceOwnerAuthentication 则是使用TouchID或者密码验证,默认是错误两次指纹或者锁定后,弹出输入密码界面;iOS 9可用
 */

+ (void)loadAuthenticationWithTouchBlock:(TouchBlock)clickBlock
{
    if (![self canPlatformSupportTouchID]) {
        NSLog(@"设备不支持");
        dispatch_async(dispatch_get_main_queue(),^{
            if(clickBlock) clickBlock(FUTouchIDStateNotSupport,0);
        });
        return;
    }
    LAContext *myContext = [[LAContext alloc] init];
    // 这个属性是设置指纹输入失败之后左侧按钮的标题
    //默认是Enter Password.为@""时，隐藏
    myContext.localizedFallbackTitle = @"";
    
    NSError *authError = nil;
    //localizedReason：用于设置提示语，表示为什么要使用Touch ID
    NSString *myLocalizedReasonString = @"轻触Home键验证已有手机指纹";
    // MARK: 判断设备是否支持指纹识别
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError])
    {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:myLocalizedReasonString reply:^(BOOL success, NSError * _Nullable error) {
            if(success)
            {
                NSLog(@"指纹认证成功");
                dispatch_async(dispatch_get_main_queue(),^{
                    if(clickBlock) clickBlock(FUTouchIDStateReplySuccess,0);
                });
            }
            else
            {
                NSLog(@"指纹认证失败，%@",error.description);
                WEAKSELF
                //指纹5次错误，锁定后，弹出密码界面
                if (error.code == LAErrorTouchIDLockout) {
                    [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:myLocalizedReasonString reply:^(BOOL success, NSError * _Nullable error) {
                        if(success)
                        {
                            NSLog(@"密码输入正确");
                            STRONGSELF
                            //密码输入正确后，继续弹出指纹验证界面
                            [strongSelf loadAuthenticationWithTouchBlock:clickBlock];
                        }
                    }];
                } else
                {
                    NSLog(@"指纹认证失败");
                    dispatch_async(dispatch_get_main_queue(),^{
                        if(clickBlock) clickBlock(FUTouchIDStateReplyFail,error.code);
                    });
                }
                switch (error.code)
                {
                    case LAErrorAuthenticationFailed: // Authentication was not successful, because user failed to provide valid credentials
                    {
                        NSLog(@"授权失败"); // -1 连续三次指纹识别错误
                    }
                        break;
                    case LAErrorUserCancel: // Authentication was canceled by user (e.g. tapped Cancel button)
                    {
                        NSLog(@"用户取消验证Touch ID"); // -2 在TouchID对话框中点击了取消按钮
                        
                    }
                        break;
                    case LAErrorUserFallback: // Authentication was canceled, because the user tapped the fallback button (Enter Password)
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"用户选择输入密码，切换主线程处理"); // -3 在TouchID对话框中点击了输入密码按钮
                        }];
                        
                    }
                        break;
                    case LAErrorSystemCancel: // Authentication was canceled by system (e.g. another application went to foreground) 
                    {
                        NSLog(@"取消授权，如其他应用切入，用户自主"); // -4 TouchID对话框被系统取消，例如按下Home或者电源键
                    }
                        break;
                    case LAErrorPasscodeNotSet: // Authentication could not start, because passcode is not set on the device.
                        
                    {
                        NSLog(@"设备系统未设置密码"); // -5
                    }
                        break;
                    case LAErrorTouchIDNotAvailable: // Authentication could not start, because Touch ID is not available on the device
                    {
                        NSLog(@"设备未设置Touch ID"); // -6
                    }
                        break;
                    case LAErrorTouchIDNotEnrolled: // Authentication could not start, because Touch ID has no enrolled fingers
                    {
                        NSLog(@"用户未录入指纹"); // -7
                    }
                        break;
                        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
                    case LAErrorTouchIDLockout: //Authentication was not successful, because there were too many failed Touch ID attempts and Touch ID is now locked. Passcode is required to unlock Touch ID, e.g. evaluating LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite 用户连续多次进行Touch ID验证失败，Touch ID被锁，需要用户输入密码解锁，先Touch ID验证密码
                    {
                        NSLog(@"Touch ID被锁，需要用户输入密码解锁"); // -8 连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
                    }
                        break;
                    case LAErrorAppCancel: // Authentication was canceled by application (e.g. invalidate was called while authentication was in progress) 如突然来了电话，电话应用进入前台，APP被挂起啦");
                    {
                        NSLog(@"用户不能控制情况下APP被挂起"); // -9
                    }
                        break;
                    case LAErrorInvalidContext: // LAContext passed to this call has been previously invalidated.
                    {
                        NSLog(@"LAContext传递给这个调用之前已经失效"); // -10
                    }
                        break;
#else
#endif
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"其他情况，切换主线程处理");
                        }];
                        break;
                    }
                }
            }
        }];
    }
    else
    {
        NSLog(@"不可用指纹");
        NSLog(@"%ld", (long)authError.code);
        dispatch_async(dispatch_get_main_queue(),^{
            if(clickBlock) clickBlock(FUTouchIDStateNotAvailable,authError.code);
        });
        switch (authError.code)
        {
            case LAErrorTouchIDNotEnrolled:
            {
                NSLog(@"Authentication could not start, because Touch ID has no enrolled fingers");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                NSLog(@"Authentication could not start, because passcode is not set on the device");
                break;
            }
            default:
            {
                NSLog(@"TouchID not available");
                break;
            }
        }
    }
}


//是否使用指纹登录
+ (void)showTouchIDAlertView:(TouchBlock)clickBlock
{
    if (![self canPlatformSupportTouchID])
    {
        if (clickBlock) clickBlock(FUTouchIDStateNotSupport,0);
    } else if (![self canEvaluatePolicy])
    {
        if (clickBlock) clickBlock(FUTouchIDStateNotAvailable,0);
    } else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"指纹解锁" message:@"是否开启指纹解锁功能" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(),^{
                if (clickBlock) clickBlock(FUTouchIDStateReplyLaterBesides,0);
            });
        }];
        UIAlertAction *startUseAction = [UIAlertAction actionWithTitle:@"指纹登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(),^{
                [self loadAuthenticationWithTouchBlock:clickBlock];
            });
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:startUseAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

//判断设备指纹识别功能是否可用
+ (BOOL)canEvaluatePolicy
{
    LAContext *context = [[LAContext alloc] init]; // 初始化上下文对象
    NSError *error = nil;
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

// 判断设备指纹识别功能是否支持，ipad端不支持
+ (BOOL)canPlatformSupportTouchID
{
    /*
     if ([platform isEqualToString:@"iPhone1,1"])   return @"iPhone1G GSM";
     if ([platform isEqualToString:@"iPhone1,2"])   return @"iPhone3G GSM";
     if ([platform isEqualToString:@"iPhone2,1"])   return @"iPhone3GS GSM";
     if ([platform isEqualToString:@"iPhone3,1"])   return @"iPhone4 GSM";
     if ([platform isEqualToString:@"iPhone3,3"])   return @"iPhone4 CDMA";
     if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone4S";
     if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone5";
     if ([platform isEqualToString:@"iPhone5,2"])   return @"iPhone5";
     if ([platform isEqualToString:@"iPhone5,3"])   return @"iPhone 5c (A1456/A1532)";
     if ([platform isEqualToString:@"iPhone5,4"])   return @"iPhone 5c (A1507/A1516/A1526/A1529)";
     if ([platform isEqualToString:@"iPhone6,1"])   return @"iPhone 5s (A1453/A1533)";
     if ([platform isEqualToString:@"iPhone6,2"])   return @"iPhone 5s (A1457/A1518/A1528/A1530)";
     */
    
    
    if(IS_Phone)
    {
        if([self platform].length > 6 )
        {
            
            NSString * numberPlatformStr = [[self platform] substringWithRange:NSMakeRange(6, 1)];
            NSInteger numberPlatform = [numberPlatformStr integerValue];
            // 是否是5s以上的设备
            if(numberPlatform > 5)
            {
                return YES;
            }
            else
            {
                return NO;
            }
            
        }
        else
        {
            return NO;
        }
    }
    else
    {
        //不支持iPad 设备
        return NO;
    }
    
}

//是否是5s以上的设备支持
+ (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

@end
