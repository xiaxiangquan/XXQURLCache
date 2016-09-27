//
//  WJNetworkReachabilityManager.m
//  WJRenovationB
//
//  Created by 夏祥全 on 16/9/23.
//  Copyright © 2016年 网家科技. All rights reserved.
//

#import "WJNetworkReachabilityManager.h"
#import "AFNetworkReachabilityManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

NSString * const WJNetworkingReachabilityDidChangeNotification = @"com.jiajuol.networking.reachability.change";
NSString * const WJNetworkingReachabilityNotificationStatusItem = @"com.jiajuol.networking.reachability.change.item";

NSString * WJStringFromNetworkReachabilityStatus(WJNetworkReachabilityStatus status) {
    switch (status) {
        case WJNetworkReachabilityStatusUnknown:
            return NSLocalizedString(@"unknown", nil);
        case WJNetworkReachabilityStatusNotReachable:
            return NSLocalizedString(@"none", nil);
        case WJNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedString(@"WWAN", nil);
        case WJNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedString(@"WIFI", nil);
        case WJNetworkReachabilityStatusReachableVia2G:
            return NSLocalizedString(@"2G", nil);
        case WJNetworkReachabilityStatusReachableVia3G:
            return NSLocalizedString(@"3G", nil);
        case WJNetworkReachabilityStatusReachableVia4G:
            return NSLocalizedString(@"4G", nil);
    }
}

@interface WJNetworkReachabilityManager()

@property (nonatomic, strong) AFNetworkReachabilityManager *reachability;
@property (nonatomic, assign) WJNetworkReachabilityStatus networkReachabilityStatus;

- (WJNetworkReachabilityStatus)_convertAFStatus:(AFNetworkReachabilityStatus)status;

@end

@implementation WJNetworkReachabilityManager

+ (instancetype)sharedManager {
    static WJNetworkReachabilityManager *monitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[WJNetworkReachabilityManager alloc] init];
        monitor.reachability = [AFNetworkReachabilityManager sharedManager];
        monitor.networkReachabilityStatus = WJNetworkReachabilityStatusUnknown;
        [[NSNotificationCenter defaultCenter] addObserver:monitor selector:@selector(wjApplicationNetworkStatusChanged:)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
    });
    return monitor;
}

- (void)dealloc {
    [self stopMonitoring];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)wjApplicationNetworkStatusChanged:(NSNotification *)userInfo {
    const AFNetworkReachabilityStatus status = [[[userInfo userInfo] objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    self.networkReachabilityStatus = [self _convertAFStatus:status];
}

- (void)setNetworkReachabilityStatus:(WJNetworkReachabilityStatus)networkReachabilityStatus {
    if (_networkReachabilityStatus != networkReachabilityStatus) {
        _networkReachabilityStatus = networkReachabilityStatus;
        if (self.callBackBlock) {
            self.callBackBlock(_networkReachabilityStatus);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:WJNetworkingReachabilityDidChangeNotification
                                                            object:nil
                                                          userInfo:@{WJNetworkingReachabilityNotificationStatusItem: @(_networkReachabilityStatus)}];
    }
}

- (void)startMonitoring {
    __weak typeof(self) weakself = self;
    [self.reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        weakself.networkReachabilityStatus = [weakself _convertAFStatus:status];
    }];
    [self.reachability startMonitoring];
}

- (void)stopMonitoring {
    [self.reachability stopMonitoring];
}

- (BOOL)isReachable {
    return self.reachability.isReachable;
}

- (BOOL)isReachableViaWWAN {
    return self.reachability.isReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.reachability.isReachableViaWiFi;
}

- (WJNetworkReachabilityStatus)wwanNetwork {
    CTTelephonyNetworkInfo *networkStatus = [[CTTelephonyNetworkInfo alloc]init];
    NSString *currentStatus  = networkStatus.currentRadioAccessTechnology;
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS] ||
        [currentStatus isEqualToString:CTRadioAccessTechnologyEdge] ||
        [currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        return WJNetworkReachabilityStatusReachableVia2G;
    }
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA] ||
        [currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA] ||
        [currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA] ||
        [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
        [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
        [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
        [currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return WJNetworkReachabilityStatusReachableVia3G;
    }
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]){
        return WJNetworkReachabilityStatusReachableVia4G;
    }
    return 0;
}

#pragma mark - private

- (WJNetworkReachabilityStatus)_convertAFStatus:(AFNetworkReachabilityStatus)status {
    switch (status) {
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return [self wwanNetwork];
        default:
            break;
    }
    return (WJNetworkReachabilityStatus)status;
}

@end
