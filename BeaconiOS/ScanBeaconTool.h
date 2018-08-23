//
//  ScanBeaconTool.h
//  BeaconiOS
//
//  Created by dongliyun on 2018/8/23.
//  Copyright © 2018年 dongliyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ScanBeaconToolDelegate<NSObject>

- (void)didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region;

- (void)didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region;

- (void)didEnterRegion:(CLRegion *)region;

- (void)didExitRegion:(CLRegion *)region;
@end

@interface ScanBeaconTool : NSObject

+ (instancetype) sharedInstance;
- (void) start;

@property (nonatomic, assign) id<ScanBeaconToolDelegate> delegate;

@end
