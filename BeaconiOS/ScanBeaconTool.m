//
//  ScanBeaconTool.m
//  BeaconiOS
//
//  Created by dongliyun on 2018/8/23.
//  Copyright © 2018年 dongliyun. All rights reserved.
//

#import "ScanBeaconTool.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface ScanBeaconTool()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, copy) NSString *defaultUUID;

@end

@implementation ScanBeaconTool

+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    static ScanBeaconTool *beaconTool;
    dispatch_once(&onceToken, ^{
        beaconTool = [[ScanBeaconTool alloc] init];
    });
    return beaconTool;
}
- (instancetype)init{
    if (self = [super init]) {
        self.locationManager.delegate = self;
        [self beaconInit];
        [self requestAuthor];
    }
    return self;
}
#pragma mark - public method

- (void)start{
    CLAuthorizationStatus authorizationStatus=[CLLocationManager authorizationStatus];
    switch (authorizationStatus){
        case kCLAuthorizationStatusNotDetermined:{
            [self.locationManager requestAlwaysAuthorization];
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            NSLog(@"受限制或者拒绝");
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            [self startScan];
        }
            break;
    }
}

- (void)stop{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
}

#pragma mark - private method

- (void) beaconInit{
    self.defaultUUID = @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825";
    self.defaultUUID = @"0CB3C111-B726-4A64-A3CB-02F77406701A";
}

-(void)addLog:(NSString *) log {
    NSLog(@"newlog:%@",log);
}

- (void) startScan{
    // range 模式
    BOOL availableRange = [CLLocationManager isRangingAvailable];
    if (availableRange){
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    } else {
        [self addLog:@"不支持range"];
    }
    // monitor 模式
    BOOL availableMonitor=[CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    if (availableMonitor) {
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }else{
        [self addLog:@"不支持monitoring"];
    }
}

- (void)requestAuthor{
    // 设置通知的类型可以为弹窗提示,声音提示,应用图标数字提示
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    // 授权通知
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
}


- (void) sendNotification:(NSString *)alertBody{
    // 1.创建通知
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    // 2.设置通知的必选参数, 设置通知显示的内容
    localNotification.alertBody = alertBody;
    // 设置通知的发送时间,单位秒
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    //解锁滑动时的事件
    localNotification.alertAction = @"别磨蹭了!";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
#pragma mark - CLLocationManagerDelegate AuthorizationStatus

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self startScan];
}

#pragma mark - CLLocationManagerDelegate Ranging

// 每秒调用一次
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region{
    NSString *log = [NSString stringWithFormat:@"[didRangeBeacons],beacons:%@",beacons.count >0 ? beacons:@0];
    [self addLog:log];
    if ([_delegate respondsToSelector:@selector(didRangeBeacons:inRegion:)]) {
        [_delegate didRangeBeacons:beacons inRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    NSLog(@"error:%@",error);
    
}
#pragma mark - CLLocationManagerDelegate Monitoring

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    NSLog(@"%s",__func__);
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    NSLog(@"%@",error);
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSLog(@"%s",__func__);
    NSString *stateString = @"未知状态";
    switch (state) {
        case CLRegionStateInside:
            stateString = @"进入区域啦";
            break;
        case CLRegionStateOutside:
            stateString = @"离开区域啦";
        default:
            break;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDetermineState:forRegion:)]) {
        [self.delegate didDetermineState:state forRegion:region];
    }
//    [self sendNotification:stateString];
    
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"%s",__func__);
//    [self sendNotification:@"小主人，上班记得打卡哦！"];
    if ([_delegate respondsToSelector:@selector(didEnterRegion:)]) {
        [_delegate didEnterRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region{
    NSLog(@"%s",__func__);
//    [self sendNotification:@"下班了，别忘记打卡哦！"];
    if ([_delegate respondsToSelector:@selector(didExitRegion:)]) {
        [_delegate didExitRegion:region];
    }
}
#pragma mark - getter and setter

- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (CLBeaconRegion *)beaconRegion{
    if (!_beaconRegion) {
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.defaultUUID] identifier:@"beacon-identifier"];
        _beaconRegion.notifyOnExit =  YES; // 离开区域收到通知，默认就是YES
        _beaconRegion.notifyOnEntry = YES;// 进入区域收到通知，默认就是YES
        _beaconRegion.notifyEntryStateOnDisplay = YES; // 屏幕点亮且在区域内时收到通知,默认是NO
    }
    return _beaconRegion;
}
@end
