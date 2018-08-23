//
//  AppDelegate.m
//  BeaconiOS
//
//  Created by dongliyun on 2018/8/9.
//  Copyright © 2018年 dongliyun. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "ScanBeaconTool.h"

@interface AppDelegate ()<CLLocationManagerDelegate,ScanBeaconToolDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[ScanBeaconTool sharedInstance] start];
    [ScanBeaconTool sharedInstance].delegate = self;
    
    [self respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]
    return YES;
}

#pragma mark - ScanBeaconToolDelegate

- (void)didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region{
    NSString *log = [NSString stringWithFormat:@"[didRangeBeacons],beacons:%@",beacons.count >0 ? beacons:@0];
    NSLog(@"%@",log);
}
- (void)didEnterRegion:(CLRegion *)region{
    [self sendNotification:@"小主人，上班记得打卡哦！"];
}
- (void)didExitRegion:(CLRegion *)region{
    [self sendNotification:@"下班了，别忘记打卡哦！"];
}

- (void)didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSString *stateString = @"delegate - 未知状态";
    switch (state) {
        case CLRegionStateInside:
            stateString = @"delegate - 进入区域啦";
            break;
        case CLRegionStateOutside:
            stateString = @"delegate - 离开区域啦";
        default:
            break;
    }
    [self sendNotification:stateString];
}

- (void)setup{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

}
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSLog(@"%s",__func__);
    
}
- (void) sendNotification:(NSString *)alertBody{
    // 1.创建通知
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    // 2.设置通知的必选参数
    // 设置通知显示的内容
    localNotification.alertBody = alertBody;
    // 设置通知的发送时间,单位秒
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    //解锁滑动时的事件
    localNotification.alertAction = @"别磨蹭了!";
    //收到通知时App icon的角标
    //    localNotification.applicationIconBadgeNumber = 1;
    //推送是带的声音提醒，设置默认的字段为UILocalNotificationDefaultSoundName
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    // 3.发送通知(? : 根据项目需要使用)
    // 方式一: 根据通知的发送时间(fireDate)发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
