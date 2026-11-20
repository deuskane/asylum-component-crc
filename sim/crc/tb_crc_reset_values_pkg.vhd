-------------------------------------------------------------------------------
-- Title      : tb_crc_reset_values_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_reset_values_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario reset_values of tb_crc, from reset :
--              Reset values : data0 and data1 are 0, the raw CRC register is 0 :
--              crc1:crc0 read its final CRC (XOR_OUT)
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

package tb_crc_reset_values_pkg is

  -- Reset values : data0 and data1 are 0, the raw CRC register is 0 :
  -- crc1:crc0 read its final CRC (XOR_OUT)
  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    );

end package tb_crc_reset_values_pkg;

package body tb_crc_reset_values_pkg is

  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    ) is
  begin
    chk(CRC_DATA0, x"00", "data0 reset value", clk, sbi_if);
    chk(CRC_DATA1, x"00", "data1 reset value", clk, sbi_if);
    dut_check(dut_final(cfg, x"0000"), "Reset value : final CRC of the raw register 0", clk, sbi_if);
  end procedure;

end package body tb_crc_reset_values_pkg;
