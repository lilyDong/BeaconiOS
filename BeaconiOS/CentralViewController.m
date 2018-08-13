//
//  CentralViewController.m
//  BeaconiOS
//
//  Created by dongliyun on 2018/8/13.
//  Copyright © 2018年 dongliyun. All rights reserved.
//

#import "CentralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

// 蓝牙设备名
static NSString * const kBlePeripheralName = @"BleTest";
// mac 模拟广播设备，设置localnamekey 无效，而是mac的名字 ???
static NSString *const kBlePeripheralName2 = @"dongliyun的MacBook Pro";

// 通知服务
static NSString * const kNotifyServerUUID = @"FFF0";
// 通知特征值
static NSString * const kNotifyCharacteristicUUID = @"FFF1";
// 写服务
static NSString * const kWriteServerUUID = @"FFE0";
// 写特征值
static NSString * const kWriteCharacteristicUUID = @"FFE1";

@interface CentralViewController()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (unsafe_unretained) IBOutlet UITextView *textView;
@property (weak) IBOutlet UIButton *startBtn;
@property (weak) IBOutlet UIButton *stopBtn;
@property (weak) IBOutlet UIButton *linkBtn;
@property (weak) IBOutlet UIButton *clearBtn;

/// 中央管理者 -->管理设备的扫描 --连接
@property (nonatomic, strong) CBCentralManager *centralManager;
// 存储的设备
@property (nonatomic, strong) NSMutableArray *peripherals;
// 扫描到的设备
@property (nonatomic, strong) CBPeripheral *cbPeripheral;
// 蓝牙状态
@property (nonatomic, assign) CBManagerState peripheralState;

@end

@implementation CentralViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (IBAction)clickStartBtn:(UIButton *)sender {
    [self showMessage:@"扫描设备"];
    if (self.peripheralState ==  CBManagerStatePoweredOn)
    {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}
- (IBAction)stopBtn:(UIButton *)sender {
    [self.centralManager stopScan];
}
- (IBAction)clickLinkBtn:(UIButton *)sender {
    if (self.cbPeripheral != nil)
    {
        [self showMessage:@"连接设备"];
        [self.centralManager connectPeripheral:self.cbPeripheral options:nil];
    }
    else
    {
        [self showMessage:@"无设备可连接"];
    }
}
- (IBAction)clickClearBtn:(UIButton *)sender {
    [self.peripherals removeAllObjects];
    
    [self showMessage:@"清空设备"];
    
    if (self.cbPeripheral != nil)
    {
        // 取消连接
        [self showMessage:@"取消连接"];
        [self.centralManager cancelPeripheralConnection:self.cbPeripheral];
    }
}

#pragma mark - CBPeripheralDelegate

/**
 扫描到设备
 
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self showMessage:[NSString stringWithFormat:@"发现设备,设备名:%@",peripheral.name]];
    
    if (![self.peripherals containsObject:peripheral])
    {
        [self.peripherals addObject:peripheral];
    }
    if ([peripheral.name isEqualToString:kBlePeripheralName] || [peripheral.name isEqualToString:kBlePeripheralName2] )
    {
        [self showMessage:[NSString stringWithFormat:@"设备名:%@",peripheral.name]];
        self.cbPeripheral = peripheral;
        
        [self showMessage:@"开始连接"];
        [self.centralManager connectPeripheral:peripheral options:nil];
        [self.centralManager stopScan];
    }
}

/**
 连接失败
 
 @param central 中心管理者
 @param peripheral 连接失败的设备
 @param error 错误信息
 */

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self showMessage:@"连接失败"];
    if ([peripheral.name isEqualToString:kBlePeripheralName])
    {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

/**
 连接断开
 
 @param central 中心管理者
 @param peripheral 连接断开的设备
 @param error 错误信息
 */

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self showMessage:@"断开连接"];
    if ([peripheral.name isEqualToString:kBlePeripheralName])
    {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

/**
 连接成功
 
 @param central 中心管理者
 @param peripheral 连接成功的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self showMessage:[NSString stringWithFormat:@"连接设备:%@成功",peripheral.name]];
    // 设置设备的代理
    peripheral.delegate = self;
    // services:传入nil  代表扫描所有服务
    [peripheral discoverServices:nil];
}

/**
 扫描到服务
 
 @param peripheral 服务对应的设备
 @param error 扫描错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 遍历所有的服务
    for (CBService *service in peripheral.services)
    {
        // 获取对应的服务
        if ([service.UUID.UUIDString isEqualToString:kNotifyServerUUID])
        {
            [self showMessage:[NSString stringWithFormat:@"服务 %@ 扫描特征值",service.UUID.UUIDString]];
            // 根据服务去扫描特征
            [peripheral discoverCharacteristics:nil forService:service];
        }
        
        if ([service.UUID.UUIDString isEqualToString:kWriteServerUUID]) {
            [self showMessage:[NSString stringWithFormat:@"服务 %@ 扫描特征值",service.UUID.UUIDString]];
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

/**
 扫描到对应的特征
 
 @param peripheral 设备
 @param service 特征对应的服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self showMessage:[NSString stringWithFormat:@"特征值们:%@",service.characteristics]];
    // 遍历所有的特征
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID])
        {
            [self showMessage:@"设置通知特征值"];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID.UUIDString isEqualToString:kWriteCharacteristicUUID]) {
            [self showMessage:@"设置写特征值"];
            Byte byte[] = {'A','B','C','D','E','F'};
            //            Byte byte[] = {0xf0, 0x3d, 0x3d, 0x01,0x02,0xf7};
            NSData *data = [NSData dataWithBytes:byte length:6];
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}

/**
 根据特征读到数据
 
 @param peripheral 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID])
    {
        NSData *data = characteristic.value;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self showMessage:str];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        [self showMessage:[NSString stringWithFormat:@"didWriteValueForCharacteristic,error:%@",error]];
    }else{
        [self showMessage:[NSString stringWithFormat:@"didWriteValueForCharacteristic 写入成功:%@",characteristic]];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    [self showMessage:[NSString stringWithFormat:@"蓝牙状态:%ld",(long)central.state]];
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
            NSLog(@"%ld",(long)self.peripheralState);
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - private method
- (void)showMessage:(NSString *)message
{
    NSLog(@"%@",message);
    self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\n",message];
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
}
#pragma mark - custom accessor
- (NSMutableArray *)peripherals{
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

@end
