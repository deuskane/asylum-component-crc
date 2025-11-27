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

  --==================================
  -- Register    : data0
  -- Description : Data byte0 - write start crc
  -- Address     : 0x0
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
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
  -- Description : Data byte1
  -- Address     : 0x1
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
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
  -- Description : CRC value byte 0
  -- Address     : 0x2
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
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
  -- Description : CRC value byte 1
  -- Address     : 0x3
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
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

  constant CRC_ADDR_WIDTH : natural := 2;
  constant CRC_DATA_WIDTH : natural := 8;

  ------------------------------------
  -- Component
  ------------------------------------
component CRC_registers is
  port (
    -- Clock and Reset
    clk_i      : in  std_logic;
    arst_b_i   : in  std_logic;
    -- Bus
    sbi_ini_i  : in  sbi_ini_t;
    sbi_tgt_o  : out sbi_tgt_t;
    -- CSR
    sw2hw_o    : out CRC_sw2hw_t;
    hw2sw_i    : in  CRC_hw2sw_t
  );
end component CRC_registers;


end package CRC_csr_pkg;
