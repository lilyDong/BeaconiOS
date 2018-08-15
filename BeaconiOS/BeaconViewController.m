//
//  BeaconViewController.m
//  BeaconiOS
//
//  Created by dongliyun on 2018/8/15.
//  Copyright © 2018年 dongliyun. All rights reserved.
//

#import "BeaconViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BeaconViewController () <CBPeripheralManagerDelegate>
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@end

@implementation BeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.uuid = @"883D7271-8BDF-44AD-85E0-42382AEBB5E5";
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    self.peripheralManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"state:%ld",peripheral.state);
    if (peripheral.state == CBManagerStatePoweredOn) {
        NSDictionary * peripheralData = [self.region peripheralDataWithMeasuredPower:@(0.25)];
        // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
        if(peripheralData)
        {
            [self.peripheralManager startAdvertising:peripheralData];
        }
    }
}

- (CLBeaconRegion *)region{
    if (!_region) {
        _region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.uuid]  major:1  minor:2 identifier:@"test-identifier"];
    }
    return _region;
}

@end
