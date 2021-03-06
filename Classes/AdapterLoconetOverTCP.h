//
//  AdapterLoconetOverTCP.h
//  Open-Touch-Throttle
//
//  Created by Tobin Richard on 13/03/10.
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

@interface AdapterLoconetOverTCP : NSObject {
@private
    NSInputStream *_istream;
    NSOutputStream *_ostream;
    NSMutableString *_inwardBuffer;
    NSMutableString *_outwardBuffer;
    BOOL _canWrite;

    // Layout state.
    NSString *_name;
    NSString *_layoutInfo;
    BOOL _trackPower;

    // Indicates whether a fatal error, such as the connection closing, has occured.
    BOOL _fatalError;

    // This is needed so we can ignore changes to the trackPower property that were caused by
    // a loconet packet from another LocoNet client.
    BOOL _lastObservedTrackState;

    // The complete set of throttles created by this adapter.
    NSMutableArray *_throttles;
}

@property (nonatomic, assign) BOOL trackPower;
@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *layoutInfo;
@property (nonatomic, readonly) BOOL fatalError;
@property (nonatomic, readonly) NSMutableArray *throttles;

- (void) cleanUp;

- (void) connectToLayoutName:(NSString *)name hostName:(NSString *)hostName port:(NSUInteger)port;
- (void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent) streamEvent;
- (void) readBytes;
- (void) processBytes;
- (void) writeBytes;
- (void) sendLocoNet:(NSString *)command;

- (void) sendTrackPower;
- (void) sendRequestAddressInfo:(NSUInteger) address;
- (void) sendRequestSlotInfo:(unsigned short) slot;
- (void) sendSlotMove:(unsigned short) from to:(unsigned short) to;
- (void) sendSlot:(unsigned short) slot speed:(double) speed;
- (void) sendSlot:(unsigned short) slot status:(unsigned short) status;
- (void) sendSlot:(unsigned short) slot forward:(BOOL)forward function0:(BOOL) f0 function1:(BOOL) f1 function2:(BOOL) f2 function3:(BOOL) f3 function4:(BOOL) f4;
- (void) parseLocoNetOverTCP:(NSString *)command;
- (void) processLocoNet:(NSData *)theBytes;
- (void) processLocoNetTwoByte:(NSData *)theBytes;
- (void) processLocoNetFourByte:(NSData *)theBytes;
- (void) processLocoNetSixByte:(NSData *)theBytes;
- (void) processLocoNetManyByte:(NSData *)theBytes withLength:(unsigned int)length;

- (id) createThrottle;

@end
