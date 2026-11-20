-------------------------------------------------------------------------------
-- Title      : tb_crc
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: UVVM/SBI self-checking testbench for sbi_crc
--              TESTS_LIST : scenarios run in sequence, separated by ','
--                           (tb_crc_tests_pkg), each one after a reset
--                           pulse ; "" : build and elaboration only
--              CFG        : DUT configuration (index in C_CRC_CFG of
--                           tb_crc_pkg, a CRC of the standard catalogue)
--              Every CRC read from the DUT is compared with a bit-serial
--              Rocksoft reference model, itself checked against the
--              catalogue check value.
--              Three crc_core instances without bus (scenario
--              core_default) : default generics (16 bits, and WIDTH_CRC = 8
--              only), and REFLECT_OUT with XOR_OUT 0x00FF (crc_o).
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-05  1.0      mrosiere Created
-- 2026-11-20  2.0      mrosiere TESTS_LIST, one package per scenario
--                               (tb_crc_<name>_pkg), helpers in
--                               tb_crc_bfm_pkg, reset pulse before each
--                               scenario, crc_core instance for the order
--                               REFLECT_OUT then XOR_OUT
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.sbi_pkg.all;
use     asylum.string_pkg.all;
use     asylum.crc_pkg.all;
use     asylum.crc_csr_pkg.all;

library work;
use     work.tb_crc_pkg.all;
use     work.tb_crc_bfm_pkg.all;
use     work.tb_crc_tests_pkg.all;

entity tb_crc is
  generic (
    TESTS_LIST       : string  := ""  -- Scenarios, e.g. "reset_values,random"
   ;CFG              : natural := 2   -- Index in C_CRC_CFG
  );
end entity tb_crc;

architecture sim of tb_crc is

  constant C_SCOPE         : string    := "TB_CRC";
  constant C_CFG           : t_crc_cfg := C_CRC_CFG(CFG);

  signal   clk_i           : std_logic := '0';
  signal   clk_ena         : boolean   := true;
  signal   arst_b_i        : std_logic := '0';

  signal   sbi_ini         : sbi_ini_t(addr (CRC_ADDR_WIDTH-1 downto 0),
                                       wdata(CRC_DATA_WIDTH-1 downto 0));
  signal   sbi_tgt         : sbi_tgt_t(rdata(CRC_DATA_WIDTH-1 downto 0));
  signal   sbi_if          : t_sbi_if (addr (CRC_ADDR_WIDTH-1 downto 0),
                                       wdata(CRC_DATA_WIDTH-1 downto 0),
                                       rdata(CRC_DATA_WIDTH-1 downto 0));

  -- crc_core instances without bus (scenario core_default)
  signal   core_d          : std_logic_vector( 8-1 downto 0) := (others => '0');
  signal   core_crc16      : std_logic_vector(16-1 downto 0) := (others => '0');
  signal   core_crc8       : std_logic_vector( 8-1 downto 0) := (others => '0');
  signal   core_next16     : std_logic_vector(16-1 downto 0);
  signal   core_next8      : std_logic_vector( 8-1 downto 0);
  signal   core_final16    : std_logic_vector(16-1 downto 0);

begin

  clock_generator(clk_i, clk_ena, C_CLK_PERIOD, "TB Clock");

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  dut : sbi_crc
    generic map
    (NAME            => "CRC"
    ,WIDTH_CRC       => C_CFG.width_crc
    ,WIDTH_DATA      => C_CFG.width_data
    ,POLYNOM         => C_CFG.polynom(C_CFG.width_crc-1 downto 0)
    ,SHIFT_LEFT      => C_CFG.shift_left
    ,LSB_FIRST       => C_CFG.lsb_first
    ,POLYNOM_REVERSE => C_CFG.polynom_reverse
    ,REFLECT_IN      => C_CFG.reflect_in
    ,REFLECT_OUT     => C_CFG.reflect_out
    ,XOR_OUT         => C_CFG.xor_out(C_CFG.width_crc-1 downto 0)
    )
    port map
    (clk_i           => clk_i
    ,arst_b_i        => arst_b_i
    ,sbi_ini_i       => sbi_ini
    ,sbi_tgt_o       => sbi_tgt
    );

  sbi_ini.cs    <= sbi_if.cs;
  sbi_ini.addr  <= std_logic_vector(sbi_if.addr);
  sbi_ini.re    <= sbi_if.rena;
  sbi_ini.we    <= sbi_if.wena;
  sbi_ini.wdata <= sbi_if.wdata;
  sbi_if.ready  <= sbi_tgt.ready;
  sbi_if.rdata  <= sbi_tgt.rdata;

  -----------------------------------------------------------------------------
  -- crc_core without bus
  -----------------------------------------------------------------------------
  -- Default generics (WIDTH_CRC = 16)
  ins_core_def16 : crc_core
    port map
    (d_i             => core_d
    ,crc_i           => core_crc16
    ,crc_next_o      => core_next16
    ,crc_o           => open
    );

  -- Default generics but WIDTH_CRC = 8
  ins_core_def8 : crc_core
    generic map
    (WIDTH_CRC       => 8
    )
    port map
    (d_i             => core_d
    ,crc_i           => core_crc8
    ,crc_next_o      => core_next8
    ,crc_o           => open
    );

  -- crc_o : REFLECT_OUT then XOR_OUT, XOR_OUT not a palindrome
  ins_core_final : crc_core
    generic map
    (REFLECT_OUT     => true
    ,XOR_OUT         => x"00FF"
    )
    port map
    (d_i             => core_d
    ,crc_i           => core_crc16
    ,crc_next_o      => open
    ,crc_o           => core_final16
    );

  -----------------------------------------------------------------------------
  -- Sequencer
  -----------------------------------------------------------------------------
  p_sequencer : process
  begin
    log(ID_LOG_HDR, "Configuration " & integer'image(CFG) & " : " & C_CFG.name &
        " WIDTH_CRC=" & integer'image(C_CFG.width_crc) & " WIDTH_DATA=" & integer'image(C_CFG.width_data) &
        ", TESTS_LIST : " & TESTS_LIST, C_SCOPE);

    -- Every name is checked before the first scenario
    for i in 1 to list_length(TESTS_LIST)
    loop
      if not list_contains(C_TESTS, list_item(TESTS_LIST, i))
      then
        alert(TB_ERROR, "Unknown test """ & list_item(TESTS_LIST, i) & """ (tests : " & C_TESTS & ")", C_SCOPE);
      end if;
    end loop;

    for i in 1 to list_length(TESTS_LIST)
    loop
      -- Reset pulse, bus inactive : each scenario starts from reset
      sbi_if <= init_sbi_if_signals(CRC_ADDR_WIDTH, CRC_DATA_WIDTH);
      do_reset(clk_i, arst_b_i);

      log(ID_LOG_HDR, "TEST " & integer'image(i) & "/" & integer'image(list_length(TESTS_LIST)) & " : " & list_item(TESTS_LIST, i), C_SCOPE);
      run_test(list_item(TESTS_LIST, i), C_CFG, 4242 + CFG, clk_i, arst_b_i, sbi_if,
               core_d, core_crc16, core_crc8, core_next16, core_next8, core_final16);
    end loop;

    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process p_sequencer;

end architecture sim;
