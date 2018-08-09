//
//  BLECentralViewController.m
//  BeaconMac
//
//  Created by dongliyun on 2018/8/9.
//  Copyright © 2018年 dongliyun. All rights reserved.
//

#import "BLECentralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

API_AVAILABLE(macos(10.13))
@interface BLECentralViewController()<CBCentralManagerDelegate,CBPeripheralDelegate>
// 中心管理者(管理设备的扫描和连接)
@property (nonatomic, strong) CBCentralManager *centralManager;
// 存储的设备
@property (nonatomic, strong) NSMutableArray *peripherals;
// 扫描到的设备
@property (nonatomic, strong) CBPeripheral *cbPeripheral;
// 文本
//@property (weak, nonatomic) IBOutlet UITextView *peripheralText;
// 外设状态
@property (nonatomic, assign) CBManagerState peripheralState;

@end

@implementation BLECentralViewController


// 扫描设备
- (IBAction)scanForPeripherals
{
    [self.centralManager stopScan];
    NSLog(@"扫描设备");
    [self showMessage:@"扫描设备"];
    if (self.peripheralState ==  CBManagerStatePoweredOn)
    {
        // 扫描所有设备,传入nil,代表所有设备.
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

#pragma mark - CBCentralManagerDelegate
// 当状态更新时调用(如果不实现会崩溃)
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:{
            NSLog(@"未知状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"重置状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"不支持的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"未授权的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"关闭状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"开启状态－可用状态");
            self.peripheralState = central.state;
        }
            break;
        default:
            break;
    }
}

#pragma mark - custom accessor

- (CBCentralManager *)centralManager
{
    if (!_centralManager)
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _centralManager;
}

- (NSMutableArray *)peripherals
{
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

@end
