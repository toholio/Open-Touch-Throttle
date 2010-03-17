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
#import "LocoNetOpCodes.h"

@interface AdapterLoconetOverTCP ()

// Add private properties and make others readwrite.
@property (nonatomic, retain) NSInputStream *istream;
@property (nonatomic, retain) NSOutputStream *ostream;
@property (nonatomic, retain) NSMutableString *outwardBuffer;
@property (nonatomic, retain) NSMutableString *inwardBuffer;
@property (nonatomic, assign) BOOL canWrite;

@property (nonatomic, assign) BOOL lastObservedTrackState;

// These are changed to read write.
@property (nonatomic, retain) NSNetService *loconetOverTCPService;

@property (nonatomic, retain) NSString *layoutInfo;
@property (nonatomic, assign) BOOL fatalError;

@end

@implementation AdapterLoconetOverTCP

@synthesize loconetOverTCPService = _loconetOverTCPService;
@synthesize trackPower = _trackPower;
@synthesize outwardBuffer = _outwardBuffer;
@synthesize inwardBuffer = _inwardBuffer;
@synthesize layoutInfo = _layoutInfo;
@synthesize fatalError = _fatalError;
@synthesize istream = _istream;
@synthesize ostream = _ostream;
@synthesize canWrite = _canWrite;
@synthesize lastObservedTrackState = _lastObservedTrackState;

- (id)initWithLocoNetOverTCPService:(NSNetService *)service {
    self = [super init];
    if ( self ) {
        self.layoutInfo = @"Unknown layout type.";
        self.lastObservedTrackState = self.trackPower;

        self.inwardBuffer = [[NSMutableString alloc] init];
        self.outwardBuffer = [[NSMutableString alloc] init];
        [self.inwardBuffer release];
        [self.outwardBuffer release];

        self.canWrite = NO;

        self.loconetOverTCPService = service;
        [self.loconetOverTCPService setDelegate:self];

        [self.loconetOverTCPService resolveWithTimeout:5.0];
    }
    return self;
}

- (void)dealloc {
    [self.loconetOverTCPService setDelegate:nil];
    [_loconetOverTCPService release];

    if ( _istream ) {
        [_istream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_istream setDelegate:nil];
        [_istream close];
        [_istream release];
    }

    if ( _ostream ) {
        [_ostream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_ostream setDelegate:nil];
        [_ostream close];
        [_ostream release];
    }

    [_inwardBuffer release];
    [_outwardBuffer release];

    [_layoutInfo release];

    [super dealloc];
}

#pragma mark Net Services methods

- (void)netServiceDidResolveAddress:(NSNetService *)netService {
    // Open the socket streams.
    NSInputStream *inStream;
    NSOutputStream *outStream;

    if ( [self.loconetOverTCPService getInputStream:&inStream outputStream:&outStream] ) {
        self.istream = inStream;
        self.ostream = outStream;

        [inStream release];
        [outStream release];

        [self.ostream open];
        [self.istream open];

        [self.ostream setDelegate:self];
        [self.istream setDelegate:self];

        [self.ostream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.istream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

        // Since we don't yet know the track power state we should request the master config slot, 0.
        [self sendRequestSlotInfo:0];

    } else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                             message:@"The LocoNetOverTCP server did not accept the connection."
                                                            delegate:self
                                                   cancelButtonTitle:@"Dismiss"
                                                   otherButtonTitles:nil];
        [errorAlert autorelease];
        [errorAlert show];

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
    if ( theStream == self.istream ) {
        switch ( streamEvent ) {
            case NSStreamEventHasBytesAvailable:
                [self readBytes];
                break;

            case NSStreamEventOpenCompleted:
                // Should set an observable property so the user may be informed.
                break;

            case NSStreamEventEndEncountered:
            case NSStreamEventErrorOccurred:
            default:
                self.fatalError = YES;
                break;
        }

    } else if ( theStream == self.ostream ) {
        switch ( streamEvent ) {
            case NSStreamEventHasSpaceAvailable:
                self.canWrite = YES;
                [self writeBytes];
                break;

            case NSStreamEventOpenCompleted:
                // Should set an observable property so the user may be informed.
                break;

            case NSStreamEventErrorOccurred:
            case NSStreamEventEndEncountered:
            default:
                self.fatalError = YES;
                break;
        }

    } else {
        NSLog( @"Unknown stream in Loconet service handler." );
    }
}

- (void) readBytes {
    uint8_t buf[1024];

    unsigned int len = 0;
    len = [self.istream read:buf maxLength:1024];

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
        self.layoutInfo = [parseScanner string];

    } else {
        NSLog( @"Got unknown command %@", command );
    }
}

- (void) writeBytes {
    if ( self.canWrite && [self.outwardBuffer length] ) {
        self.canWrite = NO;

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
    assert( [theBytes length] == 2 );

    uint8_t bytes[2];
    [theBytes getBytes:bytes];

    switch ( bytes[0] ) {
        case OPC_IDLE:
            // To be implemented.
            break;

        case OPC_GPON:
            [self setObservedTrackPower:YES];
            break;

        case OPC_GPOFF:
            [self setObservedTrackPower:NO];
            break;

        case OPC_BUSY:
            // To be implemented.
            break;

        default:
            // Unknown opcode.
            break;
    }
}

- (void) processLocoNetFourByte:(NSData *)theBytes {
    // To be implemented.
}

- (void) processLocoNetSixByte:(NSData *)theBytes {
    // To be implemented.
}

- (void) processLocoNetManyByte:(NSData *)theBytes withLength:(unsigned int)length {
    // Most opcodes remain to be implemented.

    uint8_t *bytes = malloc( sizeof(uint8_t) * [theBytes length] );
    [theBytes getBytes:bytes];

    // Make sure the packet is the size we expect.
    if ( bytes[1] == [theBytes length] ) {
        switch ( bytes[0] ) {
            case OPC_SL_RD_DATA:
                // We can examine the 5th data byte for track status. For now we only care about track power.
                [self setObservedTrackPower:bytes[7] & 0x01];
                break;

            default:
                // To be implemented.
                break;
        }
    }

    free( bytes );
}

- (void) sendLocoNet:(NSString *)command {
    [self.outwardBuffer appendString:command];
    [self.outwardBuffer appendString:@"\n"];

    if ( self.canWrite ) {
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

- (void) sendRequestSlotInfo:(unsigned short) slot {
    uint8_t bytes[4];

    bytes[0] = OPC_RQ_SL_DATA;
    bytes[1] = slot & 0x7f;
    bytes[2] = 0;
    bytes[3] = bytes[0] ^ bytes[1] ^ bytes [2] ^ 0xff;

    [self sendLocoNet:[NSString stringWithFormat:@"SEND %02X %02X %02X %02X", bytes[0], bytes[1], bytes[2], bytes[3]]];
}

- (void) setTrackPower:(BOOL)powerOn {
    _trackPower = powerOn;

    if ( _trackPower != _lastObservedTrackState ) {
        [self sendTrackPower];
    }
}

- (void) setObservedTrackPower:(BOOL)powerOn {
    self.lastObservedTrackState = powerOn;
    self.trackPower = powerOn;
}

@end
