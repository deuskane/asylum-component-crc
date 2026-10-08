# CRC
CSR for CRC

| Address | Registers |
|---------|-----------|
|0x0|data0|
|0x1|data1|
|0x2|crc0|
|0x3|crc1|

## 0x0 data0
Data byte 0 - a write of data0 processes data1:data0 (result readable one cycle later)

### [7:0] value
Data Byte 0

## 0x1 data1
Data byte 1 - bits 15:8 of the data word (write before data0, used when WIDTH_DATA > 8)

### [7:0] value
Data Byte 1

## 0x2 crc0
CRC byte 0 - write: raw CRC register bits 7:0 (seed), read: final CRC bits 7:0 (REFLECT_OUT then XOR_OUT applied)

### [7:0] value
CRC Byte 0

## 0x3 crc1
CRC byte 1 - write: raw CRC register bits 15:8 (seed), read: final CRC bits 15:8 (REFLECT_OUT then XOR_OUT applied)

### [7:0] value
CRC Byte 1

