-------------------------------------------------------------------------------
-- Title      : tb_crc_latency_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_latency_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario latency of tb_crc, from reset :
--              Latency : the CRC is readable by the access that follows the data0
--              write (one write wait state on data0), with a data word that
--              changes crc0
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

package tb_crc_latency_pkg is

  -- Latency : the CRC is readable by the access that follows the data0
  -- write (one write wait state on data0), with a data word that
  -- changes crc0
  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    );

end package tb_crc_latency_pkg;

package body tb_crc_latency_pkg is

  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    ) is
    variable v_old   : t_slv16;
    variable v_exp   : t_slv16;
    variable v_word  : t_slv16;
    variable v_found : boolean := false;
  begin
    v_old := crc_model_final(cfg, cfg.ref_init);
    for b in 0 to 255
    loop
      v_word := std_logic_vector(to_unsigned(b, 16));
      v_exp  := crc_model(cfg, cfg.ref_init, (0 => v_word));
      if v_exp(7 downto 0) /= v_old(7 downto 0)
      then
        v_found := true;
        exit;
      end if;
    end loop;
    check_value(v_found, error, "Found a data word changing crc0", C_TB_SCOPE);

    dut_set(dut_seed(cfg, cfg.ref_init), "Seed with the catalogue init", clk, sbi_if);
    wr (CRC_DATA1, v_word(15 downto 8), "Write data1"                                      , clk, sbi_if);
    wr (CRC_DATA0, v_word( 7 downto 0), "Write data0"                                      , clk, sbi_if);
    chk(CRC_CRC0 , v_exp ( 7 downto 0), "crc0 read just after the data0 write : new value" , clk, sbi_if);
    chk(CRC_CRC1 , v_exp (15 downto 8), "crc1 read after the data0 write : new value"      , clk, sbi_if);
    chk(CRC_CRC0 , v_exp ( 7 downto 0), "crc0 read again : new value"                      , clk, sbi_if);
  end procedure;

end package body tb_crc_latency_pkg;
