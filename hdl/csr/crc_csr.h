#ifndef CRC_REGISTERS_H
#define CRC_REGISTERS_H

#include <stdint.h>

// Module      : CRC
// Description : CSR for CRC
// Width       : 8

//==================================
// Register    : data0
// Description : Data byte 0 - a write of data0 processes data1:data0 (result readable one cycle later)
// Address     : 0x0
//==================================
#define CRC_DATA0 0x0

// Field       : data0.value
// Description : Data Byte 0
// Range       : [7:0]
#define CRC_DATA0_VALUE      0
#define CRC_DATA0_VALUE_MASK 255

//==================================
// Register    : data1
// Description : Data byte 1 - bits 15:8 of the data word (write before data0, used when WIDTH_DATA > 8)
// Address     : 0x1
//==================================
#define CRC_DATA1 0x1

// Field       : data1.value
// Description : Data Byte 1
// Range       : [7:0]
#define CRC_DATA1_VALUE      0
#define CRC_DATA1_VALUE_MASK 255

//==================================
// Register    : crc0
// Description : CRC byte 0 - write: raw CRC register bits 7:0 (seed), read: final CRC bits 7:0 (REFLECT_OUT then XOR_OUT applied)
// Address     : 0x2
//==================================
#define CRC_CRC0 0x2

// Field       : crc0.value
// Description : CRC Byte 0
// Range       : [7:0]
#define CRC_CRC0_VALUE      0
#define CRC_CRC0_VALUE_MASK 255

//==================================
// Register    : crc1
// Description : CRC byte 1 - write: raw CRC register bits 15:8 (seed), read: final CRC bits 15:8 (REFLECT_OUT then XOR_OUT applied)
// Address     : 0x3
//==================================
#define CRC_CRC1 0x3

// Field       : crc1.value
// Description : CRC Byte 1
// Range       : [7:0]
#define CRC_CRC1_VALUE      0
#define CRC_CRC1_VALUE_MASK 255

//----------------------------------
// Structure CRC_t
//----------------------------------
typedef struct {
  uint8_t data0; // 0x0
  uint8_t data1; // 0x1
  uint8_t crc0; // 0x2
  uint8_t crc1; // 0x3
} CRC_t;

#endif // CRC_REGISTERS_H
