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

@synthesize _loconetOverTCPService;

- (id)initWithLocoNetOverTCPService:(NSNetService *)service {
    self._loconetOverTCPService = service;
    [self._loconetOverTCPService setDelegate:self];

    [self._loconetOverTCPService resolveWithTimeout:5.0];
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

    [super dealloc];
}

#pragma mark Net Services methods

- (void)netServiceDidResolveAddress:(NSNetService *)netService {
    // Open the socket streams.
    [self._loconetOverTCPService getInputStream:&_istream outputStream:&_ostream];

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
    NSLog( @"Loconet bytes outward." );
}

@end
