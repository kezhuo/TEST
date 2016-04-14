//
//  XMGApp.m
//  11-掌握-多图下载综合案例-数据展示
//
//  Created by apple on 20/8/8.
//  Copyright © 2020年 XMG. All rights reserved.
//

#import "XMGApp.h"

@implementation XMGApp

+(instancetype)appWithDict:(NSDictionary *)dict
{
    XMGApp *app = [[XMGApp alloc]init];

    //KVC
    [app setValuesForKeysWithDictionary:dict];
    
    return app;
}
@end
