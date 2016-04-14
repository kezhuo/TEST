//
//  XMGApp.h
//  11-掌握-多图下载综合案例-数据展示
//
//  Created by apple on 20/8/8.
//  Copyright © 2020年 XMG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGApp : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *download;

+(instancetype)appWithDict:(NSDictionary *)dict;
@end
