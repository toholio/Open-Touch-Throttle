//
//  LocoNetOpCodes.h
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


// Two byte opcodes. 
#define OPC_IDLE         0x85
#define OPC_GPON         0x83
#define OPC_GPOFF        0x82
#define OPC_BUSY         0x81

// Four byte opcodes.
#define OPC_LOCO_ADR     0xbf
#define OPC_SW_ACK       0xbd
#define OPC_SW_STATE     0xbc
#define OPC_RQ_SL_DATA   0xbb
#define OPC_MOVE_SLOTS   0xba
#define OPC_LINK_SLOTS   0xb9
#define OPC_UNLINK_SLOTS 0xb8
#define OPC_CONSIST_FUNC 0xb6
#define OPC_SLOT_STAT1   0xb5
#define OPC_LONG_ACK     0xb4
#define OPC_INPUT_REP    0xb2
#define OPC_SW_REP       0xb1
#define OPC_SW_REQ       0xb0
#define OPC_LOCO_SND     0xa2
#define OPC_LOCO_DIRF    0xa1
#define OPC_LOCO_SPD     0xa0

// Six byte opcodes.
// These are reserved. Unimplemented?

// Variable length.
#define OPC_WR_SL_DATA   0xef
#define OPC_SL_RD_DATA   0xe7
#define OPC_PEER_XFER    0xe5
#define OPC_IMM_PACKET   0xed
