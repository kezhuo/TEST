//
//  ViewController.m
//  11-掌握-多图下载综合案例-数据展示
//
//  Created by apple on 20/8/8.
//  Copyright © 2020年 XMG. All rights reserved.
//

#import "ViewController.h"
#import "XMGApp.h"

@interface ViewController ()
@property (nonatomic,strong) NSArray *apps;
@property (strong, nonatomic) NSMutableDictionary*images;
@property (strong, nonatomic) NSMutableDictionary*operations;
@property (strong, nonatomic) NSOperationQueue *queue;
@end

@implementation ViewController

#pragma mark -------------------
#pragma mark lazy Loading
-(NSMutableDictionary *)images
{
    if (_images ==nil) {
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}
-(NSArray *)apps
{
    if (_apps == nil) {
        
        NSArray *apps = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps.plist" ofType:nil]];
        
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:apps.count];
        //字典转模型  字典数组--->模型数组
        for (NSDictionary *dict in apps) {
            [arrayM addObject:[XMGApp appWithDict:dict]];
        }
        _apps = arrayM;
    }
    return _apps;
}

-(NSOperationQueue *)queue
{
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 5; //设置最大并发数
    }
    return _queue;
}

-(NSMutableDictionary *)operations
{
    if (_operations == nil) {
        _operations  = [NSMutableDictionary dictionary];
    }
    return _operations;
}

#pragma mark -------------------
#pragma mark UITableDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.apps.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.创建cell
    static NSString *ID = @"app";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //2.设置数据
    //2.0 先拿到该行cell对应的数据
    XMGApp *appM = self.apps[indexPath.row];
    
    //2.1 设置标题
    cell.textLabel.text = appM.name;
    
    //2.2 设置子标题
    cell.detailTextLabel.text = [NSString stringWithFormat:@"下载量:%@",appM.download];
    
    //2.3 设置图片
    //当图片下载完成之后显示图片,& 保存到字典中去
    //当该图片需要显示的时候,先检查内存缓存,如果有那么就直接使用内存缓存,否则在下载
    UIImage *image = [self.images objectForKey:appM.icon];
    if(image)
    {
        cell.imageView.image = image;
        NSLog(@"%zd---内存缓存",indexPath.row);
    }else
    {
        //拼接caches路径
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        //拼接文件的全路径
        NSString *fileName = [appM.icon lastPathComponent];
        NSString *fullPath = [cachesPath stringByAppendingPathComponent:fileName];

        //检查磁盘缓存
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        //为了演示方便
        data = nil;
        if (data) {
                //设置
            UIImage *image = [UIImage imageWithData:data];
            cell.imageView.image = image;
            
                //保存到内存缓存
            [self.images setObject:image forKey:appM.icon];
            
              NSLog(@"%zd---磁盘缓存",indexPath.row);
        }else
        {
            
            //处理image
            //cell.imageView.image = nil;
            
            //设置占位图片
            cell.imageView.image = [UIImage imageNamed:@"Snip20200808_29"];
            //检查该图片的下载操作是否已经存在,如果存在,那么什么都不做,等待
            NSBlockOperation *download = [self.operations objectForKey:appM.icon];
            
            if (download) {
                
            }else
            {
                //封装操作
                download = [NSBlockOperation blockOperationWithBlock:^{
                    
                    NSURL *url = [NSURL URLWithString:appM.icon];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    
                    for (NSInteger i = 0; i<1000000000; i++) {
                        
                    }
                    
                    UIImage *image = [UIImage imageWithData:data];
                    
                     NSLog(@"%zd---开始下载-----",indexPath.row);
                    
                    if (image == nil) {
                        [self.operations removeObjectForKey:appM.icon];
                        return ;
                    }
                    //保存到内存缓存
                    [self.images setObject:image forKey:appM.icon];
                    
                    //保存到磁盘缓存
                    [data writeToFile:fullPath atomically:YES];
                   
                    
                    //回到主线程设置图片
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        //cell.imageView.image = image;
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                        NSLog(@"%zd---下载结束++++++",indexPath.row);
                        //NSLog(@"UI---%@",[NSThread currentThread]);
                    }];
                    
                }];
                
                //做操作缓存
                [self.operations setObject:download forKey:appM.icon];
                //添加操作到队列中
                [self.queue addOperation:download];
            }
        }
    }
    //3.返回cell
    return cell;
}

-(void)didReceiveMemoryWarning
{
    [self.images removeAllObjects];
     self.images = nil;
    
    [self.queue cancelAllOperations];
}
//磁盘缓存的路径
/*
 Documents :会备份&不允许 (X)
 Library
    caches
    perference  偏好设置
 tmp :临时数据
 */
/*
 1)UI卡顿 --->开子线程下载图片
        图片不显示(fram=0)--->刷新指定的行
        重复下载的问题(因为图片下载操作需要花费时间,在该时间段内部此image有需要显示)
        对图片的下载操作进行缓存--->操作缓存
 2)重复下载的问题-->内存缓存
 */
//二级缓存
/*
 显示--> 内存缓存 -->下载
 显示--> 内存缓存 -->磁盘缓存 -->下载
 */
@end
