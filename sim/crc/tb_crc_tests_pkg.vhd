-------------------------------------------------------------------------------
-- Title      : tb_crc_tests_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_tests_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenarios of tb_crc : names (valid items of TESTS_LIST) and
--              dispatch (run_test) to the package of each scenario
--              (tb_crc_<name>_pkg)
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.string_pkg.all;

library work;
use     work.tb_crc_pkg.all;
use     work.tb_crc_bfm_pkg.all;

package tb_crc_tests_pkg is

  -- Names of the scenarios (valid items of TESTS_LIST)
  constant C_TESTS : string := "core_default,reset_values,register_access,check_value,latency,seed_after_data,random,async_reset";

  -- Run the scenario name
  procedure run_test
    (constant name     : in    string
    ;constant cfg      : in    t_crc_cfg        -- DUT configuration
    ;constant seed     : in    positive         -- Seed of the random values
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic        -- arst_b_i
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   core_d   : out   std_logic_vector -- d_i of the crc_core instances
    ;signal   crc16    : out   std_logic_vector -- crc_i, 16-bit instances
    ;signal   crc8     : out   std_logic_vector -- crc_i, 8-bit instance
    ;signal   next16   : in    std_logic_vector -- crc_next_o, default generics
    ;signal   next8    : in    std_logic_vector -- crc_next_o, WIDTH_CRC = 8
    ;signal   final16  : in    std_logic_vector -- crc_o, REFLECT_OUT, XOR_OUT 0x00FF
    );

end package tb_crc_tests_pkg;

package body tb_crc_tests_pkg is

  procedure run_test
    (constant name     : in    string
    ;constant cfg      : in    t_crc_cfg
    ;constant seed     : in    positive
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   core_d   : out   std_logic_vector
    ;signal   crc16    : out   std_logic_vector
    ;signal   crc8     : out   std_logic_vector
    ;signal   next16   : in    std_logic_vector
    ;signal   next8    : in    std_logic_vector
    ;signal   final16  : in    std_logic_vector
    ) is
  begin
    if    string_eq(name, "core_default")
    then
      work.tb_crc_core_default_pkg.run(core_d, crc16, crc8, next16, next8, final16);
    elsif string_eq(name, "reset_values")
    then
      work.tb_crc_reset_values_pkg.run(cfg, clk, sbi_if);
    elsif string_eq(name, "register_access")
    then
      work.tb_crc_register_access_pkg.run(cfg, seed, clk, sbi_if);
    elsif string_eq(name, "check_value")
    then
      work.tb_crc_check_value_pkg.run(cfg, clk, sbi_if);
    elsif string_eq(name, "latency")
    then
      work.tb_crc_latency_pkg.run(cfg, clk, sbi_if);
    elsif string_eq(name, "seed_after_data")
    then
      work.tb_crc_seed_after_data_pkg.run(cfg, clk, sbi_if);
    elsif string_eq(name, "random")
    then
      work.tb_crc_random_pkg.run(cfg, seed, clk, sbi_if);
    elsif string_eq(name, "async_reset")
    then
      work.tb_crc_async_reset_pkg.run(cfg, clk, arst_b, sbi_if);
    else
      alert(TB_ERROR, "Unknown test " & name, C_TB_SCOPE);
    end if;
  end procedure;

end package body tb_crc_tests_pkg;
