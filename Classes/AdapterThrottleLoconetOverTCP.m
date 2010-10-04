//
//  AdapterThrottleLoconetOverTCP.m
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

#import "AdapterThrottleLoconetOverTCP.h"
#import "AdapterLoconetOverTCP.h"
#import "LocoNetOpCodes.h"

@implementation AdapterThrottleLoconetOverTCP

@synthesize layoutAdapter = _layoutAdapter;
@synthesize locoAddress = _locoAddress;

- (id) initWithLayoutAdapter:(AdapterLoconetOverTCP *)theLayoutAdapter {
    self = [super init];
    if ( self ) {
        memset( _slotData, 0, 11 );
        self.layoutAdapter = theLayoutAdapter;
        self.locoAddress = LOCO_ADDRESS_INVALID;

        self.locoAddress = 3;
    }
    return self;
}

- (void) setLocoAddress:(NSUInteger) theLocoAddress {
    // If we already have an address, release it here.
    if ( _locoAddress != LOCO_ADDRESS_INVALID ) {
        [self.layoutAdapter sendSlot:self.locoSlot status:_slotData[1] & 0xcf];
    }

    _locoAddress = theLocoAddress;

    if ( _locoAddress != LOCO_ADDRESS_INVALID ) {
        // Start looking for the new address.
        [self.layoutAdapter sendRequestAddressInfo:theLocoAddress];
    }
}

- (void) processSlotRead:(NSData *)theBytes {
    assert( [theBytes length] == 14 );

    uint8_t bytes[14];
    [theBytes getBytes:bytes];

    // Check the slot status, if it's available we will use it.
    unsigned int status = (bytes[3] & 0x30) >> 4;
    if ( status == SL_IDLE || status == SL_COMMON || status == SL_FREE ) {
        // Do a null move.
        _shouldGainSlot = YES;
        [self.layoutAdapter sendSlotMove:bytes[2] to:bytes[2]];

    } else if ( _shouldGainSlot ) {
        _shouldGainSlot = NO;
        // The throttle is ours.

        // Copy the complete slot data.
        memcpy( _slotData, bytes + 2, 11 );

        [self didChangeValueForKey:@"locoSpeed"];
        [self didChangeValueForKey:@"locoForward"];
    }
}

- (void) setLocoSpeed:(float) theSpeed {
    // Internally we only deal with integer speeds.
    unsigned short speed = theSpeed * 127;

    if ( self.locoSlot > 0 ) {
        // Speed 1 is zero speed for emergency stop make sure we don't set this.
        if ( speed == 1 ) {
            speed++;
        }

        if ( _slotData[3] != speed ) {
            _slotData[3] = speed;

            [self.layoutAdapter sendSlot:self.locoSlot speed:self.locoSpeed];
        }
    }
}

- (float) locoSpeed {
    return _slotData[3] / 127.0;
}

- (void) setLocoForward:(BOOL) isForward {
    if ( self.locoSlot > 0 ) {
        if ( isForward != ( _slotData[4] & 0x20 ) ) {
            if ( isForward ) {
                _slotData[4] |= 0x20;
            } else {
                _slotData[4] &= 0xdf;
            }

            [self.layoutAdapter sendSlot:self.locoSlot forward:self.locoForward function0:YES function1:NO function2:NO function3:NO function4:NO];
        }
    }
}

- (BOOL) locoForward {
    return _slotData[4] & 0x20;
}

- (uint8_t) locoSlot {
    return _slotData[0];
}

@end
