//
//  AdapterLoconetOverTCP.m
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

#import "AdapterLoconetOverTCP.h"

@implementation AdapterLoconetOverTCP

@synthesize loconetOverTCPService = _loconetOverTCPService;
@synthesize trackPower = _trackPower;
@synthesize outwardBuffer = _outwardBuffer;

- (id)initWithLocoNetOverTCPService:(NSNetService *)service {
    self = [super init];
    if ( self ) {
        self.outwardBuffer = [[NSMutableString alloc] init];
        _canWrite = NO;

        self.loconetOverTCPService = service;
        [self.loconetOverTCPService setDelegate:self];

        [self.loconetOverTCPService resolveWithTimeout:5.0];

        [self addObserver:self forKeyPath:@"trackPower" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    }
    return self;
}

- (void)dealloc {
    [_loconetOverTCPService setDelegate:nil];
    [_loconetOverTCPService release];

    if ( _istream ) {
        [_istream setDelegate:nil];
        [_istream close];
        [_istream release];
    }

    if ( _ostream ) {
        [_ostream setDelegate:nil];
        [_ostream close];
        [_ostream release];
    }

    [_outwardBuffer release];

    [super dealloc];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( [keyPath isEqualToString:@"trackPower"] ) {
        if ( [[change objectForKey:NSKeyValueChangeNewKey] boolValue] != [[change objectForKey:NSKeyValueChangeOldKey] boolValue] ) {
            [self sendTrackPower];
        }
    }
}

#pragma mark Net Services methods

- (void)netServiceDidResolveAddress:(NSNetService *)netService {
    // Open the socket streams.
    [self.loconetOverTCPService getInputStream:&_istream outputStream:&_ostream];

    if ( !_istream || !_ostream ) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                             message:@"The LocoNetOverTCP server did not accept the connection."
                                                            delegate:self
                                                   cancelButtonTitle:@"Dismiss"
                                                   otherButtonTitles:nil];
        [errorAlert autorelease];
        [errorAlert show];

    } else {
        [_ostream open];
        [_istream open];

        [_ostream setDelegate:self];
        [_istream setDelegate:self];

        [_ostream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_istream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)netService:(NSNetService *)netService didNotResolve:(NSDictionary *)errorDict {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                         message:@"Could not get the connection information from the LocoNetOverTCP server."
                                                        delegate:self
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil];
    [errorAlert autorelease];
    [errorAlert show];
}

#pragma mark Stream methods.

- (void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent) streamEvent {
    if ( theStream == _istream ) {
        switch ( streamEvent ) {
            case NSStreamEventHasBytesAvailable:
                [self readBytes];
                break;

            case NSStreamEventEndEncountered:
                break;

            case NSStreamEventErrorOccurred:
                break;

            case NSStreamEventOpenCompleted:
                break;

            default:
                NSLog( @"Unknown stream event in Loconet service handler." );
                break;
        }

    } else if ( theStream == _ostream ) {
        switch ( streamEvent ) {
            case NSStreamEventHasSpaceAvailable:
                _canWrite = YES;
                [self writeBytes];
                break;

            case NSStreamEventErrorOccurred:
                break;

            case NSStreamEventOpenCompleted:
                break;

            case NSStreamEventEndEncountered:
                break;

            default:
                NSLog( @"Unknown stream event in Loconet service handler." );
                break;
        }

    } else {
        NSLog( @"Unknown stream in Loconet service handler." );
    }    
}

- (void) readBytes {
    NSLog( @"Loconet bytes inward." );
}

- (void) writeBytes {
    if ( _canWrite && [self.outwardBuffer length] ) {
        _canWrite = NO;

        // Make a set of data from the string.
        NSData *buffer = [self.outwardBuffer dataUsingEncoding:NSASCIIStringEncoding];
        int bytesWritten = [_ostream write:[buffer bytes] maxLength:[buffer length]];

        if ( bytesWritten > 0 ) {
            NSData *remainingData = [NSData dataWithBytes:([buffer bytes] + bytesWritten) length:([buffer length] - bytesWritten)];
            NSString *remainingString = [[NSString alloc] initWithData:remainingData encoding:NSASCIIStringEncoding];
            [self.outwardBuffer setString:remainingString];
            [remainingString autorelease];
        }
    }
}

#pragma mark Layout Methods.

- (void) sendLocoNet:(NSString *)command {
    [self.outwardBuffer appendString:command];
    [self.outwardBuffer appendString:@"\n"];

    if ( _canWrite ) {
        [self writeBytes];
    }
}

- (void) sendTrackPower {
    if ( self.trackPower ) {
        [self sendLocoNet:@"SEND 83 7C"];
    } else {
        [self sendLocoNet:@"SEND 82 7D"];
    }
}

@end
