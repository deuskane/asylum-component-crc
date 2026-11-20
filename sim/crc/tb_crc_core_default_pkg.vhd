-------------------------------------------------------------------------------
-- Title      : tb_crc_core_default_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_core_default_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario core_default of tb_crc, from reset :
--              crc_core alone, without the bus : the default generics give
--              CRC-16/XMODEM (WIDTH_CRC = 16) and CRC-8/SMBUS (WIDTH_CRC = 8) on
--              the check message ; crc_o applies REFLECT_OUT then XOR_OUT (XOR_OUT
--              0x00FF is not a palindrome : the order is visible)
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.crc_csr_pkg.all;

library work;
use     work.tb_crc_pkg.all;
use     work.tb_crc_bfm_pkg.all;

package tb_crc_core_default_pkg is

  -- crc_core alone, without the bus : the default generics give
  -- CRC-16/XMODEM (WIDTH_CRC = 16) and CRC-8/SMBUS (WIDTH_CRC = 8) on
  -- the check message ; crc_o applies REFLECT_OUT then XOR_OUT (XOR_OUT
  -- 0x00FF is not a palindrome : the order is visible)
  procedure run
    (signal   core_d  : out   std_logic_vector -- d_i of the crc_core instances
    ;signal   crc16   : out   std_logic_vector -- crc_i, 16-bit instances
    ;signal   crc8    : out   std_logic_vector -- crc_i, 8-bit instance
    ;signal   next16  : in    std_logic_vector -- crc_next_o, default generics
    ;signal   next8   : in    std_logic_vector -- crc_next_o, WIDTH_CRC = 8
    ;signal   final16 : in    std_logic_vector -- crc_o, REFLECT_OUT, XOR_OUT 0x00FF
    );

end package tb_crc_core_default_pkg;

package body tb_crc_core_default_pkg is

  procedure run
    (signal   core_d  : out   std_logic_vector -- d_i of the crc_core instances
    ;signal   crc16   : out   std_logic_vector -- crc_i, 16-bit instances
    ;signal   crc8    : out   std_logic_vector -- crc_i, 8-bit instance
    ;signal   next16  : in    std_logic_vector -- crc_next_o, default generics
    ;signal   next8   : in    std_logic_vector -- crc_next_o, WIDTH_CRC = 8
    ;signal   final16 : in    std_logic_vector -- crc_o, REFLECT_OUT, XOR_OUT 0x00FF
    ) is
    variable v_crc16 : std_logic_vector(16-1 downto 0) := (others => '0');
    variable v_crc8  : std_logic_vector( 8-1 downto 0) := (others => '0');
    type     t_val_array is array (natural range <>) of t_slv16;
    constant C_VAL   : t_val_array(0 to 1) := (x"1234", x"0001");
  begin
    for i in C_CHECK_MSG'range
    loop
      core_d <= C_CHECK_MSG(i)(7 downto 0);
      crc16  <= v_crc16;
      crc8   <= v_crc8;
      wait for 1 ns;
      v_crc16 := next16;
      v_crc8  := next8;
    end loop;
    chk_val(v_crc16, x"31C3", "Default generics : CRC-16/XMODEM check value of ""123456789""");
    chk_val(v_crc8 , x"F4"  , "Default generics, WIDTH_CRC = 8 : CRC-8/SMBUS check value of ""123456789""");

    for i in C_VAL'range
    loop
      crc16 <= C_VAL(i);
      wait for 1 ns;
      chk_val(final16, reflect(C_VAL(i), 16) xor x"00FF", "crc_o : REFLECT_OUT then XOR_OUT");
    end loop;
  end procedure;

end package body tb_crc_core_default_pkg;
