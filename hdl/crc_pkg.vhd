-------------------------------------------------------------------------------
-- Title      : crc_pkg
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : crc_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Component declarations of crc_core and sbi_crc,
--              default polynomial (crc_default_polynom)
-------------------------------------------------------------------------------
-- Copyright (c) 2025
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2025-11-27  1.0      mrosiere Created
-- 2026-10-05  1.1      mrosiere crc_core : add port crc_o
-------------------------------------------------------------------------------
library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
library asylum;
use     asylum.sbi_pkg.all;

package crc_pkg is

  -----------------------------------------------------------------------------
  -- Default POLYNOM of crc_core / sbi_crc (normal form, implicit MSB not
  -- included) for the default generics (SHIFT_LEFT, MSB first, no reflection)
  --   WIDTH_CRC =  8 : 0x07       CRC-8/SMBUS
  --   WIDTH_CRC = 16 : 0x1021     CRC-16/XMODEM (CRC-16/CCITT-FALSE with the
  --                               seed 0xFFFF)
  --   WIDTH_CRC = 32 : 0x04C11DB7 CRC-32/MPEG-2 with the seed 0xFFFFFFFF
  --                               (crc_core only, sbi_crc is limited to 16)
  -- Other widths : no default, POLYNOM must be set (failure at elaboration)
  -----------------------------------------------------------------------------
  function crc_default_polynom (width : positive) return std_logic_vector;

-- [COMPONENT_INSERT][BEGIN]
component crc_core is
  generic (
    WIDTH_CRC       : positive := 16;
    WIDTH_DATA      : positive := 8;
    POLYNOM         : std_logic_vector(WIDTH_CRC-1 downto 0) := crc_default_polynom(WIDTH_CRC); -- see crc_default_polynom
    SHIFT_LEFT      : boolean := true;                                          -- TRUE = shift left, FALSE = shift right
    LSB_FIRST       : boolean := false;                                         -- TRUE = process LSB first, FALSE = MSB first
    POLYNOM_REVERSE : boolean := false;                                         -- TRUE = reverse polynomial bits
    REFLECT_IN      : boolean := false;                                         -- TRUE = reflect input data bits
    REFLECT_OUT     : boolean := false;                                         -- TRUE = reflect CRC output bits
    XOR_OUT         : std_logic_vector(WIDTH_CRC-1 downto 0) := (others => '0') -- XOR mask for output
  );
  port (
    d_i        : in  std_logic_vector(WIDTH_DATA-1 downto 0); -- Data word
    crc_i      : in  std_logic_vector(WIDTH_CRC -1 downto 0); -- Current CRC register (raw)
    crc_next_o : out std_logic_vector(WIDTH_CRC -1 downto 0); -- CRC register after d_i (raw, feed back to crc_i)
    crc_o      : out std_logic_vector(WIDTH_CRC -1 downto 0)  -- Final CRC of crc_i (REFLECT_OUT then XOR_OUT)
  );
end component crc_core;

component sbi_crc is
  generic (
    NAME            : string  := "";
    WIDTH_CRC       : positive := 16;
    WIDTH_DATA      : positive :=  8;
    POLYNOM         : std_logic_vector(WIDTH_CRC-1 downto 0) := crc_default_polynom(WIDTH_CRC); -- see crc_default_polynom
    SHIFT_LEFT      : boolean := true;                                          -- TRUE = shift left, FALSE = shift right
    LSB_FIRST       : boolean := false;                                         -- TRUE = process LSB first, FALSE = MSB first
    POLYNOM_REVERSE : boolean := false;                                         -- TRUE = reverse polynomial bits
    REFLECT_IN      : boolean := false;                                         -- TRUE = reflect input data bits
    REFLECT_OUT     : boolean := false;                                         -- TRUE = reflect CRC output bits
    XOR_OUT         : std_logic_vector(WIDTH_CRC-1 downto 0) := (others => '0') -- XOR mask for output
  );
  port   (
    clk_i            : in    std_logic;
    arst_b_i         : in    std_logic; -- asynchronous reset

    -- Bus
    sbi_ini_i        : in    sbi_ini_t;
    sbi_tgt_o        : out   sbi_tgt_t
    );

end component sbi_crc;

-- [COMPONENT_INSERT][END]

end crc_pkg;

package body crc_pkg is

  function crc_default_polynom (width : positive) return std_logic_vector is
    variable res : std_logic_vector(width-1 downto 0) := (others => '0');
  begin
    case width is
      when  8     => res := x"07";
      when 16     => res := x"1021";
      when 32     => res := x"04C11DB7";
      when others =>
        report "crc : no default POLYNOM for WIDTH_CRC = " & integer'image(width) & ", the generic POLYNOM must be set"
          severity failure;
    end case;
    return res;
  end function crc_default_polynom;

end package body crc_pkg;
