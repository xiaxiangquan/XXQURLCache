//
//  WJURLCache.h
//  XXQKeychainDemo
//
//  Created by 夏祥全 on 16/9/27.
//  Copyright © 2016年 夏祥全. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDURLCache.h"
#import <UIKit/UIKit.h>

typedef void(^wjRemoveCachedResponseBlock) (BOOL status);

@interface WJURLCache : SDURLCache

- (void)wjRemoveCachedURLResponseWithComplete:(wjRemoveCachedResponseBlock)complete;
- (NSString *)wjGetLocalDiskCacheFileSize;


@end
