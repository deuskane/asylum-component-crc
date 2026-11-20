-------------------------------------------------------------------------------
-- Title      : tb_crc_seed_after_data_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_seed_after_data_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario seed_after_data of tb_crc, from reset :
--              Write of the CRC just after a data0 write : the CRC update of data0
--              is not lost, the write then overwrites its byte of the raw register
--              (crc0 for WIDTH_CRC > 8 ; crc1, above WIDTH_CRC, for WIDTH_CRC <= 8).
--              The update of data0 (wait state cycle) and a software write of the
--              CRC never happen in the same cycle : the priority of the software
--              write in sbi_crc cannot be observed from the bus
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

package tb_crc_seed_after_data_pkg is

  -- Write of the CRC just after a data0 write : the CRC update of data0
  -- is not lost, the write then overwrites its byte of the raw register
  -- (crc0 for WIDTH_CRC > 8 ; crc1, above WIDTH_CRC, for WIDTH_CRC <= 8).
  -- The update of data0 (wait state cycle) and a software write of the
  -- CRC never happen in the same cycle : the priority of the software
  -- write in sbi_crc cannot be observed from the bus
  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    );

end package tb_crc_seed_after_data_pkg;

package body tb_crc_seed_after_data_pkg is

  procedure run
    (constant cfg     : in    t_crc_cfg -- DUT configuration
    ;signal   clk     : in    std_logic
    ;signal   sbi_if  : inout t_sbi_if
    ) is
    variable v_crc   : t_slv16;
  begin
    dut_set  (x"0000", "Seed 0"            , clk, sbi_if);
    dut_word (x"00A5", "Write data1, data0", clk, sbi_if);
    -- Raw register : update by data0, then one byte overwritten
    v_crc := dut_seed(cfg, crc_model_step(cfg, x"0000", x"00A5"));
    if cfg.width_crc > 8
    then
      wr(CRC_CRC0, x"3C", "Write crc0 just after data0", clk, sbi_if);
      v_crc( 7 downto 0) := x"3C";
    else
      wr(CRC_CRC1, x"3C", "Write crc1 (above WIDTH_CRC) just after data0", clk, sbi_if);
      v_crc(15 downto 8) := x"3C";
    end if;
    dut_check(dut_final(cfg, v_crc), "Raw register = data0 update, then the CRC byte written", clk, sbi_if);
  end procedure;

end package body tb_crc_seed_after_data_pkg;
