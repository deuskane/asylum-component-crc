-------------------------------------------------------------------------------
-- Title      : tb_crc_async_reset_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_async_reset_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario async_reset of tb_crc, from reset :
--              Asynchronous reset : a pulse between two rising edges of the clock
--              resets data0, data1 and the raw CRC register
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

package tb_crc_async_reset_pkg is

  -- Asynchronous reset : a pulse between two rising edges of the clock
  -- resets data0, data1 and the raw CRC register
  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   arst_b  : out   std_logic -- arst_b_i
    ;signal   sbi_if  : inout t_sbi_if
    );

end package tb_crc_async_reset_pkg;

package body tb_crc_async_reset_pkg is

  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   arst_b  : out   std_logic -- arst_b_i
    ;signal   sbi_if  : inout t_sbi_if
    ) is
  begin
    dut_set  (x"FFFF", "Seed 0xFFFF"       , clk, sbi_if);
    dut_word (x"1234", "Write data1, data0", clk, sbi_if);
    chk(CRC_DATA0, x"34", "data0 before the reset", clk, sbi_if);
    chk(CRC_DATA1, x"12", "data1 before the reset", clk, sbi_if);

    -- Reset pulse without rising edge of the clock
    wait until falling_edge(clk);
    arst_b <= '0';
    wait for C_CLK_PERIOD/4;
    arst_b <= '1';
    wait until rising_edge(clk);

    chk(CRC_DATA0, x"00", "data0 after reset", clk, sbi_if);
    chk(CRC_DATA1, x"00", "data1 after reset", clk, sbi_if);
    dut_check(dut_final(cfg, x"0000"), "After reset : final CRC of the raw register 0", clk, sbi_if);
  end procedure;

end package body tb_crc_async_reset_pkg;
