//
//  AdapterThrottleLoconetOverTCP.h
//  Open-Touch-Throttle
//
//  Created by Tobin Richard on 20/03/10.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

#import <Foundation/Foundation.h>

#define LOCO_ADDRESS_INVALID NSUIntegerMax

@class AdapterLoconetOverTCP;

@interface AdapterThrottleLoconetOverTCP : NSObject {
    AdapterLoconetOverTCP *_layoutAdapter;
    NSUInteger _locoAddress;
    BOOL _shouldGainSlot;
    BOOL _lookingForSlot;
    uint8_t _slotData[11];
    BOOL _error;
    NSString *_errorMessage;
}

@property (nonatomic, retain) AdapterLoconetOverTCP *layoutAdapter;
@property (nonatomic, assign) NSUInteger locoAddress;
@property (nonatomic, assign) float locoSpeed;
@property (nonatomic, assign) BOOL locoForward;
@property (nonatomic, readonly) uint8_t locoSlot;
@property (nonatomic, readonly) BOOL error;
@property (nonatomic, readonly, retain) NSString *errorMessage;

- (id) initWithLayoutAdapter:(AdapterLoconetOverTCP *)theLayoutAdapter;
- (void) processSlotRead:(NSData *)theBytes;

@end
