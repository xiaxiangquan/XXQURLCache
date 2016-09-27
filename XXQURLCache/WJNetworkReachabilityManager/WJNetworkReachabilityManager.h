//
//  WJNetworkReachabilityManager.h
//  WJRenovationB
//
//  Created by 夏祥全 on 16/9/23.
//  Copyright © 2016年 网家科技. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, WJNetworkReachabilityStatus) {
    WJNetworkReachabilityStatusUnknown          = -1,     //不知名网络
    WJNetworkReachabilityStatusNotReachable     = 0,  //没有网络
    WJNetworkReachabilityStatusReachableViaWWAN = 1, // 细分为2G，3G，4G，WWAN用不到
    WJNetworkReachabilityStatusReachableViaWiFi = 2,
    WJNetworkReachabilityStatusReachableVia2G   = 3,
    WJNetworkReachabilityStatusReachableVia3G   = 4,
    WJNetworkReachabilityStatusReachableVia4G   = 5,
};

FOUNDATION_EXPORT NSString * const WJNetworkingReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString * const WJNetworkingReachabilityNotificationStatusItem;
FOUNDATION_EXPORT NSString * WJStringFromNetworkReachabilityStatus(WJNetworkReachabilityStatus status);

@interface WJNetworkReachabilityManager : NSObject

@property (nonatomic, readonly) WJNetworkReachabilityStatus networkReachabilityStatus;
@property (nonatomic, readonly, getter = isReachable) BOOL reachable;
@property (nonatomic, readonly, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
@property (nonatomic, readonly, getter = isReachableViaWiFi) BOOL reachableViaWiFi;
@property (nonatomic, copy) void(^callBackBlock)(WJNetworkReachabilityStatus networkStatus);

+ (instancetype)sharedManager;
- (void)startMonitoring;
- (void)stopMonitoring;

@end
