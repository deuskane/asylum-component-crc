# asylum-component-crc

A flexible and configurable CRC (Cyclic Redundancy Check) computation component for hardware implementations. This repository contains synthesizable VHDL modules that provide both combinatorial CRC computation and a register-based interface for system integration.

## Table of Contents

- [Introduction](#introduction)
- [HDL Modules](#hdl-modules)
  - [crc_core](#crc_core)
  - [sbi_crc](#sbi_crc)
  - [crc_pkg](#crc_pkg)
  - [crc_csr](#crc_csr)
- [Register Map](#register-map)
- [Verification](#verification)

## Introduction

The CRC component provides a highly configurable CRC computation engine suitable for various industrial CRC standards including CRC-16, CRC-32, and custom polynomial configurations. The component supports:

- **Flexible data widths**: Configurable input data width (default 8 bits)
- **Variable CRC width**: Configurable CRC polynomial width (default 16 bits)
- **Multiple polynomial options**: Support for any polynomial or standard variants
- **Bit ordering control**: LSB-first or MSB-first processing
- **Shift direction**: Left or right shift modes
- **Reflection modes**: Input/output reflection for reflected variants
- **XOR output masking**: Final XOR mask capability
- **System integration**: Register-based interface for SoC integration

The component is designed as part of the Asylum framework and can be integrated into larger systems via the SBI (Simple Bus Interface).

## HDL Modules

### crc_core

**File**: hdl/crc_core.vhd

The core combinatorial CRC computation engine that performs polynomial-based CRC calculation on input data.

#### Generics

| Generic Name | Type | Default | Description |
|---|---|---|---|
| WIDTH_CRC | positive | 16 | Width of the CRC polynomial and register (bits) |
| WIDTH_DATA | positive | 8 | Width of input data (bits) |
| POLYNOM | std_logic_vector | x"1021" | CRC polynomial without implicit MSB (e.g., 0x1021 for CRC-16-CCITT) |
| SHIFT_LEFT | boolean | false | TRUE = shift left mode, FALSE = shift right mode |
| LSB_FIRST | boolean | false | TRUE = process bits LSB first, FALSE = process bits MSB first |
| POLYNOM_REVERSE | boolean | false | TRUE = reverse polynomial bits, FALSE = use polynomial as-is |
| REFLECT_IN | boolean | false | TRUE = reflect/reverse input data bits, FALSE = use data as-is |
| REFLECT_OUT | boolean | false | TRUE = reflect/reverse final CRC output, FALSE = use CRC as-is |
| XOR_OUT | std_logic_vector | (others => '0') | XOR mask applied to final CRC output |

#### Ports

| Port Name | Direction | Width | Description |
|---|---|---|---|
| d_i | in | WIDTH_DATA | Input data byte(s) to be processed by CRC |
| crc_i | in | WIDTH_CRC | Current CRC value (feedback register) |
| crc_next_o | out | WIDTH_CRC | Next CRC value (combinatorial result) |

#### Operation

The crc_core module implements a parallel CRC computation using a combinatorial architecture. For each input bit, it:

1. XORs the feedback bit with the appropriate data bit (determined by LSB_FIRST)
2. Shifts the CRC register left or right (controlled by SHIFT_LEFT)
3. Applies the polynomial feedback if the feedback bit is '1'
4. Reflects both input and/or output data if configured
5. Applies the final XOR mask before output

The module supports both reflected and non-reflected CRC variants through configuration, enabling compatibility with standard CRC algorithms like CRC-16, CRC-32, etc.

---

### sbi_crc

**File**: hdl/sbi_crc.vhd

A register-mapped CRC component providing a system bus interface for integration into larger systems. It wraps the crc_core engine with register management and SBI bus protocol support.

#### Generics

Same as crc_core module (see above table).

#### Ports

| Port Name | Direction | Type | Description |
|---|---|---|---|
| clk_i | in | std_logic | System clock |
| rst_b_i | in | std_logic | Asynchronous reset (active low) |
| sbi_ini_i | in | sbi_ini_t | SBI initiator signals (bus requests) |
| sbi_tgt_o | out | sbi_tgt_t | SBI target signals (bus responses) |

#### Operation

The sbi_crc module integrates the CRC computation engine with a register file accessible through the SBI bus interface. It:

1. Accepts data writes via the SBI bus to data0 and data1 registers
2. Automatically triggers CRC computation when data0 is written
3. Updates CRC value registers (crc0 and crc1) with the computed result
4. Supports software read/write access to all CRC registers
5. Provides a stateful CRC accumulation for multi-byte processing

---

### crc_pkg

**File**: hdl/crc_pkg.vhd

VHDL package containing component declarations for crc_core and sbi_crc modules, enabling instantiation in other designs.

---

### crc_csr

**Files**: 
- hdl/csr/crc_csr.vhd - Generated register file
- hdl/csr/crc_csr_pkg.vhd - Generated package with CSR types
- hdl/csr/crc_csr.h - Generated C header file
- hdl/csr/crc.hjson - Register definition (source)

The CSR (Control/Status Register) module provides the register interface for the SBI bus. It is automatically generated from crc.hjson using the 
egtool generator in the FuseSoC build process.

## Register Map

The CRC component provides four 8-bit registers accessible through the SBI bus interface. For detailed bitfield information, see [hdl/csr/crc_csr.md](hdl/csr/crc_csr.md).

| Address | Register Name | Access | Description |
|---|---|---|---|
| 0x0 | data0 | RW | Data Byte 0 - Write triggers CRC computation |
| 0x1 | data1 | RW | Data Byte 1 |
| 0x2 | crc0 | RW | CRC Output Byte 0 |
| 0x3 | crc1 | RW | CRC Output Byte 1 |

### Register Details

#### 0x0 - data0 (Data Byte 0)
Data byte 0 - writing to this register triggers CRC computation with data0 and data1

**Bitfield [7:0] value**: Data Byte 0

#### 0x1 - data1 (Data Byte 1)
Data byte 1

**Bitfield [7:0] value**: Data Byte 1

#### 0x2 - crc0 (CRC Output Byte 0)
CRC value byte 0 (read-write from software perspective)

**Bitfield [7:0] value**: CRC Byte 0

#### 0x3 - crc1 (CRC Output Byte 1)
CRC value byte 1 (read-write from software perspective)

**Bitfield [7:0] value**: CRC Byte 1

For complete register and bitfield definitions, refer to [hdl/csr/crc_csr.md](hdl/csr/crc_csr.md).
