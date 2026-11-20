-------------------------------------------------------------------------------
-- Title      : tb_crc_check_value_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_check_value_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario check_value of tb_crc, from reset :
--              Catalogue check value : the reference model gives the check value
--              of "123456789" ; the DUT, seeded with the catalogue init, gives the
--              CRC of the model after each word and the check value at the end
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

package tb_crc_check_value_pkg is

  -- Catalogue check value : the reference model gives the check value
  -- of "123456789" ; the DUT, seeded with the catalogue init, gives the
  -- CRC of the model after each word and the check value at the end
  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    );

end package tb_crc_check_value_pkg;

package body tb_crc_check_value_pkg is

  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    ) is
    variable v_crc   : t_slv16;
    variable v_cfg8  : t_crc_cfg;
  begin
    -- Reference model against the catalogue
    if cfg.check_valid
    then
      chk_val(crc_model(cfg, cfg.ref_init, C_CHECK_MSG), cfg.check, "Model check value of ""123456789""");
    end if;
    if cfg.width_data = 16
    then
      -- 16-bit words MSB first must give the same CRC as the bytes MSB first
      v_cfg8            := cfg;
      v_cfg8.width_data := 8;
      chk_val(crc_model(cfg   , cfg.ref_init, C_CHECK_MSG16),
              crc_model(v_cfg8, cfg.ref_init, C_CHECK_MSG(0 to 7)),
              "Model : 16-bit words equal to 2 bytes MSB first");
    end if;

    -- DUT, intermediate CRC after each word
    dut_set(dut_seed(cfg, cfg.ref_init), "Seed with the catalogue init", clk, sbi_if);
    v_crc := cfg.ref_init;
    if cfg.width_data = 8
    then
      for i in C_CHECK_MSG'range
      loop
        dut_word (C_CHECK_MSG(i), "Check message word " & integer'image(i), clk, sbi_if);
        v_crc := crc_model_step(cfg, v_crc, C_CHECK_MSG(i));
        dut_check(crc_model_final(cfg, v_crc), "CRC after word " & integer'image(i), clk, sbi_if);
      end loop;
      if cfg.check_valid
      then
        dut_check(cfg.check, "Catalogue check value", clk, sbi_if);
      end if;
    else
      for i in C_CHECK_MSG16'range
      loop
        dut_word (C_CHECK_MSG16(i), "Check message word " & integer'image(i), clk, sbi_if);
        v_crc := crc_model_step(cfg, v_crc, C_CHECK_MSG16(i));
        dut_check(crc_model_final(cfg, v_crc), "CRC after word " & integer'image(i), clk, sbi_if);
      end loop;
    end if;
  end procedure;

end package body tb_crc_check_value_pkg;
