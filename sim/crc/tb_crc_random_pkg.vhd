-------------------------------------------------------------------------------
-- Title      : tb_crc_random_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_random_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario random of tb_crc, from reset :
--              32 random messages of 1 to 16 words with a random init ; random
--              bits above WIDTH_CRC in the seed and above WIDTH_DATA in the data
--              (data1 when WIDTH_DATA = 8) : ignored. WIDTH_DATA = 8 : data1 is
--              written before the first word only, then data0 only (one write per
--              byte, as the software does)
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

package tb_crc_random_pkg is

  -- 32 random messages of 1 to 16 words with a random init ; random
  -- bits above WIDTH_CRC in the seed and above WIDTH_DATA in the data
  -- (data1 when WIDTH_DATA = 8) : ignored. WIDTH_DATA = 8 : data1 is
  -- written before the first word only, then data0 only (one write per
  -- byte, as the software does)
  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;constant seed    : in    positive -- Seed of the random values
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    );

end package tb_crc_random_pkg;

package body tb_crc_random_pkg is

  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;constant seed    : in    positive -- Seed of the random values
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    ) is
    constant C_NB_MSG : natural  := 32;
    variable v_seed1  : positive := 17;
    variable v_seed2  : positive := seed;
    variable v_len    : natural;
    variable v_init   : t_slv16;
    variable v_rnd    : t_slv16;
    variable v_word   : t_slv16;
    variable v_crc    : t_slv16;
  begin
    for m in 0 to C_NB_MSG-1
    loop
      random(1, 16, v_seed1, v_seed2, v_len);
      random(v_seed1, v_seed2, v_init);
      v_init := v_init and mask(cfg.width_crc);
      random(v_seed1, v_seed2, v_rnd);
      dut_set(dut_seed(cfg, v_init) or (v_rnd and not mask(cfg.width_crc)), "Random seed", clk, sbi_if);
      v_crc  := v_init;
      for i in 0 to v_len-1
      loop
        random(v_seed1, v_seed2, v_word);
        if cfg.width_data <= 8 and i > 0
        then
          wr(CRC_DATA0, v_word(7 downto 0), "Random word (data0 only)", clk, sbi_if);
        else
          dut_word(v_word, "Random word", clk, sbi_if);
        end if;
        v_crc  := crc_model_step(cfg, v_crc, v_word);
      end loop;
      dut_check(crc_model_final(cfg, v_crc), "Message " & integer'image(m) & " (" & integer'image(v_len) & " words)", clk, sbi_if);
    end loop;
  end procedure;

end package body tb_crc_random_pkg;
