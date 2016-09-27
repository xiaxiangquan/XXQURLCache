//
//  WJURLCache.m
//  XXQKeychainDemo
//
//  Created by 夏祥全 on 16/9/27.
//  Copyright © 2016年 夏祥全. All rights reserved.
//

#import "WJURLCache.h"
#import "WJNetworkReachabilityManager.h"
#import "JSONKit.h"
#import "SDCachedURLResponse.h"

@interface WJURLCache()


@end

@implementation WJURLCache

- (NSDate *)convertTimestamp:(NSString *)timestamp {
    NSTimeInterval time = ([timestamp floatValue] / 1000.0);
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    return detaildate;
}

+ (NSURLRequest *)convertRequestForRequest:(NSURLRequest *)request {
    NSString *urlStr = request.URL.absoluteString;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[urlStr componentsSeparatedByString:@"&"]];
    for (NSString *string in [urlStr componentsSeparatedByString:@"&"]) {
        if ([string hasPrefix:@"sign"]) {
            [arr removeObject:string];
        }
    }
    NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[arr componentsJoinedByString:@"&"]]];
    return newRequest;
}


- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {

    NSDate *date = [self convertTimestamp:[[cachedResponse.data objectFromJSONData] objectForKey:@"time_stamp"]];
    NSInteger expirationTime = [request.allHTTPHeaderFields[WJCACHE_EXPIRATION_TIME] integerValue];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:cachedResponse.userInfo];
    userInfo[CustomURLCacheExpirationKey] = [date dateByAddingTimeInterval:expirationTime];    
    NSCachedURLResponse *modifiedCachedResponse = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response
                                                                                           data:cachedResponse.data
                                                                                       userInfo:userInfo
                                                                                  storagePolicy:cachedResponse.storagePolicy];
    NSURLRequest *newRequest = [WJURLCache convertRequestForRequest:request];
    [super storeCachedResponse:modifiedCachedResponse forRequest:newRequest];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    NSURLRequest *newRequest = [WJURLCache convertRequestForRequest:request];
    NSCachedURLResponse *urlResponse = [super cachedResponseForRequest:newRequest];
    if (urlResponse == nil) {
        return nil;
    }
    // 判断过期时间 是否过期
    if ([urlResponse.userInfo[CustomURLCacheExpirationKey] compare:[NSDate date]] == NSOrderedAscending) {
        
        if ([[WJNetworkReachabilityManager sharedManager] isReachable]) {
            return nil;
        } else {
            return urlResponse;
        }
    } else {
        return urlResponse;
    }
    return nil;
}

- (void)wjRemoveCachedURLResponseWithComplete:(wjRemoveCachedResponseBlock)complete {
    [self removeAllCachedResponses];
    if (complete) {
        complete(YES);
    }
}

- (NSString *)wjGetLocalDiskCacheFileSize {
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:self.diskCachePath])
        return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:self.diskCachePath] objectEnumerator];
    NSString* fileName;
    CGFloat folderSize = 0.0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    NSString *cacheSize = [NSString stringWithFormat:@"%.2f",folderSize / (1000.0*1000.0)];
    return cacheSize;
}

- (CGFloat)fileSizeAtPath:(NSString*) filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        CGFloat size = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        
        return size;
    }
    return 0;
}

@end













