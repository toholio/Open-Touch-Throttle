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
    NSMutableString *_outwardBuffer;
    BOOL _canWrite;

    // Layout state.
    BOOL _trackPower;
}

@property (nonatomic, retain) NSNetService *loconetOverTCPService;
@property (nonatomic, assign) BOOL trackPower;
@property (nonatomic, retain) NSMutableString *outwardBuffer;

- (id) initWithLocoNetOverTCPService:(NSNetService *)service;

- (void) netServiceDidResolveAddress:(NSNetService *)netService;
- (void) netService:(NSNetService *)netService didNotResolve:(NSDictionary *)errorDict;

- (void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent) streamEvent;
- (void) readBytes;
- (void) writeBytes;
- (void) sendLocoNet:(NSString *)command;

- (void) sendTrackPower;

@end
