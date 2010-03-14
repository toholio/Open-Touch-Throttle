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
    NSNetService *_loconetOverTCPService;

    NSInputStream *_istream;
    NSOutputStream *_ostream;
    NSMutableString *_inwardBuffer;
    NSMutableString *_outwardBuffer;
    BOOL _canWrite;

    // Layout state.
    NSString *_layoutInfo;
    BOOL _trackPower;

    // This is needed so we can ignore changes to the trackPower property that were caused by
    // a loconet packet from another LocoNet client.
    BOOL _lastObservedTrackState;
}

@property (nonatomic, retain) NSNetService *loconetOverTCPService;
@property (nonatomic, assign) BOOL trackPower;
@property (nonatomic, retain) NSMutableString *outwardBuffer;
@property (nonatomic, retain) NSMutableString *inwardBuffer;
@property (nonatomic, retain) NSString *layoutInfo;

- (id) initWithLocoNetOverTCPService:(NSNetService *)service;

- (void) netServiceDidResolveAddress:(NSNetService *)netService;
- (void) netService:(NSNetService *)netService didNotResolve:(NSDictionary *)errorDict;

- (void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent) streamEvent;
- (void) readBytes;
- (void) processBytes;
- (void) writeBytes;
- (void) sendLocoNet:(NSString *)command;

- (void) sendTrackPower;
- (void) parseLocoNetOverTCP:(NSString *)command;
- (void) processLocoNet:(NSData *)theBytes;
- (void) processLocoNetTwoByte:(NSData *)theBytes;
- (void) processLocoNetFourByte:(NSData *)theBytes;
- (void) processLocoNetSixByte:(NSData *)theBytes;
- (void) processLocoNetManyByte:(NSData *)theBytes withLength:(unsigned int)length;
@end
