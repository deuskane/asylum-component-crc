#ifndef CRC_REGISTERS_H
#define CRC_REGISTERS_H

#include <stdint.h>

// Module      : CRC
// Description : CSR for CRC
// Width       : 8

//==================================
// Register    : data0
// Description : Data byte0 - write start crc
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
// Description : Data byte1
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
// Description : CRC value byte 0
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
// Description : CRC value byte 1
// Address     : 0x3
//==================================
#define CRC_CRC1 0x3

// Field       : crc1.value
// Description : CRC Byte 1
// Range       : [7:0]
#define CRC_CRC1_VALUE      0
#define CRC_CRC1_VALUE_MASK 255

//----------------------------------
// Structure {module}_t
//----------------------------------
typedef struct {
  uint8_t data0; // 0x0
  uint8_t data1; // 0x1
  uint8_t crc0; // 0x2
  uint8_t crc1; // 0x3
} CRC_t;

#endif // CRC_REGISTERS_H
