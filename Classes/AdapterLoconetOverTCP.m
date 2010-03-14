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
@synthesize inwardBuffer = _inwardBuffer;

- (id)initWithLocoNetOverTCPService:(NSNetService *)service {
    self = [super init];
    if ( self ) {
        self.inwardBuffer = [[NSMutableString alloc] init];
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

    [_inwardBuffer release];
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
    uint8_t buf[1024];

    unsigned int len = 0;
    len = [_istream read:buf maxLength:1024];

    if ( len ) {
        NSData *tempData = [NSData dataWithBytes:buf length:len];
        NSString *tempString = [[NSString alloc] initWithData:tempData encoding:NSASCIIStringEncoding];

        [self.inwardBuffer appendString:tempString];
        [tempString autorelease];
        [self processBytes];
    }
}

- (void) processBytes {
    // Search backwards to the last end of line. If there is no end of line we can't have finished a command.
    NSRange nlPos = [self.inwardBuffer rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];

    // Check to see if there was actually a line end.
    if ( nlPos.location == NSNotFound ) {
        return;
    }

    // Get the complete commands for processing.
    NSString *toProcess = [self.inwardBuffer substringToIndex:nlPos.location];

    // Remove the remaining input for later processing.
    [self.inwardBuffer setString:[self.inwardBuffer substringFromIndex:nlPos.location]];

    // Scan and dispatch the commands.
    NSString *command;
    NSScanner *commandScanner = [NSScanner scannerWithString:toProcess];

    while ( [commandScanner isAtEnd] == NO ) {
        [commandScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&command];
        [self parseLocoNetOverTCP:command];
    }
}

- (void) parseLocoNetOverTCP:(NSString *)command {
    // Determine the type.
    // Currently the only commands in the specification are RECEIVE and VERSION.
    NSString *segment;

    NSScanner *parseScanner = [NSScanner scannerWithString:command];
    [parseScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&segment];

    if ( [segment isEqualToString:@"RECEIVED"] ) {
        // Get the data bytes.
        NSMutableData *bytes = [[NSMutableData alloc] init];
        [bytes autorelease];
        unsigned readInt;
        while ( [parseScanner scanHexInt:&readInt] ) {
            if ( readInt > 0xff ) {
                NSLog( @"Command contained a larger than byte value: %x.", readInt );
                return;
            }

            uint8_t byte = readInt;
            [bytes appendBytes:&byte length:1];
        }

        // Check there were actually bytes.
        if ( [bytes length] == 0 ) {
            NSLog( @"No bytes were read." );
            return;
        }

        // Submit the packet for processing.
        [self processLocoNet:bytes];

    } else if ( [segment isEqualToString:@"VERSION"] ) {
        // Should store this value for display.

    } else {
        NSLog( @"Got unknown command %@", command );
    }
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

- (void) processLocoNet:(NSData *)theBytes {
    BOOL packetOK = YES;

    // Packets must be at least two bytes.
    if ( [theBytes length] < 2 ) {
        packetOK = NO;
    }

    // Get an indexable array of bytes.
    uint8_t *bytes = malloc( sizeof(uint8_t) * [theBytes length] );
    [theBytes getBytes:bytes];

    // Is the MSB set for the opcode byte?
    packetOK = packetOK && ( bytes[0] & 0x80 );

    // Are there any other opcodes?
    for ( int index = 1; packetOK && index < [theBytes length]; index++ ) {
        packetOK = packetOK && !( bytes[index] & 0x80 );
    }

    // Determine the correct packet length.
    unsigned int expectedLength;
    switch ( bytes[0] & 0x60 ) {
        case 0x0:
            expectedLength = 2;
            break;

        case 0x20:
            expectedLength = 4;
            break;

        case 0x40:
            expectedLength = 6;
            break;

        default:
            // Examine the next byte for the length.
            expectedLength = bytes[1];
    }

    // Check the length matches.
    packetOK = packetOK && ( expectedLength == [theBytes length] );

    // Examine the checksum.
    int checksum = 0;
    for ( int index = 0; index < [theBytes length]; index++ ) {
        checksum ^= bytes[index];
    }

    packetOK = packetOK && ( checksum == 0xff );

    free( bytes );

    if ( packetOK ) {
        // So now we can actually handle the packets.
        switch ( expectedLength ) {
            case 2:
                [self processLocoNetTwoByte:theBytes];
                break;

            case 4:
                [self processLocoNetFourByte:theBytes];
                break;

            case 6:
                [self processLocoNetSixByte:theBytes];
                break;

            default:
                [self processLocoNetManyByte:theBytes withLength:expectedLength];
                break;
        }
    }
}

- (void) processLocoNetTwoByte:(NSData *)theBytes {
    // To be implemented.
}

- (void) processLocoNetFourByte:(NSData *)theBytes {
    // To be implemented.
}

- (void) processLocoNetSixByte:(NSData *)theBytes {
    // To be implemented.
}

- (void) processLocoNetManyByte:(NSData *)theBytes withLength:(unsigned int)length {
    // To be implemented.
}

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
