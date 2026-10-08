-- Generated VHDL Package for CRC

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library asylum;
use     asylum.sbi_pkg.all;
--==================================
-- Module      : CRC
-- Description : CSR for CRC
-- Width       : 8
--==================================

package CRC_csr_pkg is

  ------------------------------------
  -- Global Constants
  ------------------------------------

  constant CRC_ADDR_WIDTH : natural := 2;
  constant CRC_DATA_WIDTH : natural := 8;

  --==================================
  -- Register    : data0
  -- Description : Data byte 0 - a write of data0 processes data1:data0 (result readable one cycle later)
  -- Address     : 0x0
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  constant CRC_DATA0 : unsigned(CRC_ADDR_WIDTH-1 downto 0) := to_unsigned(0, CRC_ADDR_WIDTH);

  type CRC_data0_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : Data Byte 0
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record CRC_data0_sw2hw_t;

  --==================================
  -- Register    : data1
  -- Description : Data byte 1 - bits 15:8 of the data word (write before data0, used when WIDTH_DATA > 8)
  -- Address     : 0x1
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  constant CRC_DATA1 : unsigned(CRC_ADDR_WIDTH-1 downto 0) := to_unsigned(1, CRC_ADDR_WIDTH);

  type CRC_data1_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : Data Byte 1
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record CRC_data1_sw2hw_t;

  --==================================
  -- Register    : crc0
  -- Description : CRC byte 0 - write: raw CRC register bits 7:0 (seed), read: final CRC bits 7:0 (REFLECT_OUT then XOR_OUT applied)
  -- Address     : 0x2
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : ext
  --==================================
  constant CRC_CRC0 : unsigned(CRC_ADDR_WIDTH-1 downto 0) := to_unsigned(2, CRC_ADDR_WIDTH);

  type CRC_crc0_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : CRC Byte 0
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record CRC_crc0_sw2hw_t;

  type CRC_crc0_hw2sw_t is record
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : CRC Byte 0
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record CRC_crc0_hw2sw_t;

  --==================================
  -- Register    : crc1
  -- Description : CRC byte 1 - write: raw CRC register bits 15:8 (seed), read: final CRC bits 15:8 (REFLECT_OUT then XOR_OUT applied)
  -- Address     : 0x3
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : ext
  --==================================
  constant CRC_CRC1 : unsigned(CRC_ADDR_WIDTH-1 downto 0) := to_unsigned(3, CRC_ADDR_WIDTH);

  type CRC_crc1_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : CRC Byte 1
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record CRC_crc1_sw2hw_t;

  type CRC_crc1_hw2sw_t is record
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : CRC Byte 1
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record CRC_crc1_hw2sw_t;

  ------------------------------------
  -- Structure CRC_t
  ------------------------------------
  type CRC_sw2hw_t is record
    data0 : CRC_data0_sw2hw_t;
    data1 : CRC_data1_sw2hw_t;
    crc0 : CRC_crc0_sw2hw_t;
    crc1 : CRC_crc1_sw2hw_t;
  end record CRC_sw2hw_t;

  type CRC_hw2sw_t is record
    crc0 : CRC_crc0_hw2sw_t;
    crc1 : CRC_crc1_hw2sw_t;
  end record CRC_hw2sw_t;

  ------------------------------------
  -- Component
  ------------------------------------
component CRC_registers is
  generic (
    MODULE_NAME :  string := "" -- Name of the module
  );
  port (
    -- Clock and Reset
    clk_i      : in  std_logic
   ;arst_b_i   : in  std_logic
    -- Bus
   ;sbi_ini_i  : in  sbi_ini_t
   ;sbi_tgt_o  : out sbi_tgt_t
    -- CSR
   ;sw2hw_o    : out CRC_sw2hw_t
   ;hw2sw_i    : in  CRC_hw2sw_t
  );
end component CRC_registers;


end package CRC_csr_pkg;
