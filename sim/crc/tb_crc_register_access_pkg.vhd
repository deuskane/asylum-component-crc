-------------------------------------------------------------------------------
-- Title      : tb_crc_register_access_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_register_access_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario register_access of tb_crc, from reset :
--              Register access : data0 and data1 read back ; crc0 / crc1 write
--              the raw CRC register and read the final CRC (REFLECT_OUT then
--              XOR_OUT), the bits above WIDTH_CRC are ignored and read as 0
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

package tb_crc_register_access_pkg is

  -- Register access : data0 and data1 read back ; crc0 / crc1 write
  -- the raw CRC register and read the final CRC (REFLECT_OUT then
  -- XOR_OUT), the bits above WIDTH_CRC are ignored and read as 0
  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;constant seed    : in    positive -- Seed of the random values
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    );

end package tb_crc_register_access_pkg;

package body tb_crc_register_access_pkg is

  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;constant seed    : in    positive -- Seed of the random values
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    ) is
    variable v_seed1 : positive := 17;
    variable v_seed2 : positive := seed;
    variable v_word  : t_slv16;
  begin
    wr (CRC_DATA1, x"5A", "Write data1"    , clk, sbi_if);
    chk(CRC_DATA1, x"5A", "Read back data1", clk, sbi_if);
    wr (CRC_DATA0, x"A5", "Write data0"    , clk, sbi_if);
    chk(CRC_DATA0, x"A5", "Read back data0", clk, sbi_if);
    for i in 0 to 3
    loop
      random(v_seed1, v_seed2, v_word);
      dut_set  (v_word                 , "Write random raw CRC register"             , clk, sbi_if);
      dut_check(dut_final(cfg, v_word) , "Read final CRC of the written raw register", clk, sbi_if);
    end loop;
  end procedure;

end package body tb_crc_register_access_pkg;
