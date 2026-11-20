-------------------------------------------------------------------------------
-- Title      : tb_crc_bfm_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_bfm_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Helpers of the tb_crc scenarios : SBI accesses (SBI VIP, at
--              most one wait state : data0), checks, raw CRC register seed,
--              data word, final CRC check, reset pulse.
--              Values are 16-bit (t_slv16 of tb_crc_pkg) : crc1:crc0 and
--              data1:data0.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (helpers of tb_crc)
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

package tb_crc_bfm_pkg is

  constant C_TB_SCOPE    : string  := "TB_CRC_BFM";
  constant C_CLK_PERIOD  : time    := 20 ns;

  subtype  byte_t is std_logic_vector(8-1 downto 0);

  -- data0 has one write wait state, the other accesses none : any access
  -- with more than one cycle with ready = '0' is an error
  constant C_SBI_CFG     : t_sbi_bfm_config := (
    max_wait_cycles            => 1,
    max_wait_cycles_severity   => error,
    use_fixed_wait_cycles_read => false,
    fixed_wait_cycles_read     => 0,
    clock_period               => -1 ns,
    clock_period_margin        => 0 ns,
    clock_margin_severity      => TB_ERROR,
    setup_time                 => -1 ns,
    hold_time                  => -1 ns,
    bfm_sync                   => SYNC_ON_CLOCK_ONLY,
    match_strictness           => MATCH_EXACT,
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL,
    use_ready_signal           => true
  );

  -- SBI write
  procedure wr
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- SBI read and check
  procedure chk
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- Check of a value computed by the testbench (model, crc_core output)
  procedure chk_val
    (constant val      : in    std_logic_vector
    ;constant exp      : in    std_logic_vector
    ;constant msg      : in    string
    );

  -- Write the seed (raw CRC register) in crc0 then crc1
  procedure dut_set
    (constant seed     : in    t_slv16
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- Process one data word : data1 then data0 (data1 is always written, it
  -- must be ignored when WIDTH_DATA <= 8)
  procedure dut_word
    (constant word     : in    t_slv16
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- Read and check crc0 then crc1 (final CRC)
  procedure dut_check
    (constant exp      : in    t_slv16
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- Reset pulse, released on a falling edge
  procedure do_reset
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    );

end package tb_crc_bfm_pkg;

package body tb_crc_bfm_pkg is

  procedure wr
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    sbi_write(addr_value => addr
             ,data_value => data
             ,msg        => msg
             ,clk        => clk
             ,sbi_if     => sbi_if
             ,scope      => C_TB_SCOPE
             ,config     => C_SBI_CFG
             );
  end procedure;

  procedure chk
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    sbi_check(addr_value  => addr
             ,data_exp    => data
             ,msg         => msg
             ,clk         => clk
             ,sbi_if      => sbi_if
             ,alert_level => error
             ,scope       => C_TB_SCOPE
             ,config      => C_SBI_CFG
             );
  end procedure;

  procedure chk_val
    (constant val      : in    std_logic_vector
    ;constant exp      : in    std_logic_vector
    ;constant msg      : in    string
    ) is
  begin
    check_value(val, exp, error, msg, C_TB_SCOPE);
  end procedure;

  procedure dut_set
    (constant seed     : in    t_slv16
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    wr(CRC_CRC0, seed( 7 downto 0), msg & " (crc0)", clk, sbi_if);
    wr(CRC_CRC1, seed(15 downto 8), msg & " (crc1)", clk, sbi_if);
  end procedure;

  procedure dut_word
    (constant word     : in    t_slv16
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    wr(CRC_DATA1, word(15 downto 8), msg & " (data1)", clk, sbi_if);
    wr(CRC_DATA0, word( 7 downto 0), msg & " (data0)", clk, sbi_if);
  end procedure;

  procedure dut_check
    (constant exp      : in    t_slv16
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    chk(CRC_CRC0, exp( 7 downto 0), msg & " (crc0)", clk, sbi_if);
    chk(CRC_CRC1, exp(15 downto 8), msg & " (crc1)", clk, sbi_if);
  end procedure;

  procedure do_reset
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ) is
  begin
    arst_b <= '0';
    wait for 100 ns;
    wait until falling_edge(clk);
    arst_b <= '1';
    wait until rising_edge(clk);
  end procedure;

end package body tb_crc_bfm_pkg;
