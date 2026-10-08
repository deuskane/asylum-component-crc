-------------------------------------------------------------------------------
-- Title      : tb_crc
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: UVVM/SBI self-checking testbench for sbi_crc
--              The DUT configuration is selected by the generic CFG
--              (see C_CRC_CFG in tb_crc_pkg). Every CRC read from the DUT is
--              compared with a bit-serial Rocksoft reference model, itself
--              checked against the catalogue check value.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-05  1.0      mrosiere Created
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.sbi_pkg.all;
use     asylum.crc_pkg.all;
use     asylum.crc_csr_pkg.all;

use     work.tb_crc_pkg.all;

entity tb_crc is
  generic (
    CFG : natural := 2 -- Index in C_CRC_CFG
  );
end entity tb_crc;

architecture sim of tb_crc is

  constant C_SCOPE      : string    := "TB_CRC";
  constant C_CFG        : t_crc_cfg := C_CRC_CFG(CFG);
  constant C_ADDR_WIDTH : natural   := CRC_ADDR_WIDTH;
  constant C_DATA_WIDTH : natural   := CRC_DATA_WIDTH;
  constant C_NB_MSG     : natural   := 32;  -- Number of random messages

  signal clk_i          : std_logic := '0';
  signal clk_ena        : boolean   := true;
  signal arst_b_i       : std_logic := '0';

  signal sbi_ini        : sbi_ini_t(addr (C_ADDR_WIDTH-1 downto 0),
                                    wdata(C_DATA_WIDTH-1 downto 0));
  signal sbi_tgt        : sbi_tgt_t(rdata(C_DATA_WIDTH-1 downto 0));

  signal sbi_if         : t_sbi_if(addr (C_ADDR_WIDTH-1 downto 0),
                                   wdata(C_DATA_WIDTH-1 downto 0),
                                   rdata(C_DATA_WIDTH-1 downto 0));

begin

  clock_generator(clk_i, clk_ena, 20 ns, "TB Clock");

  ins_dut : sbi_crc
    generic map (
      NAME            => "CRC",
      WIDTH_CRC       => C_CFG.width_crc,
      WIDTH_DATA      => C_CFG.width_data,
      POLYNOM         => C_CFG.polynom(C_CFG.width_crc-1 downto 0),
      SHIFT_LEFT      => C_CFG.shift_left,
      LSB_FIRST       => C_CFG.lsb_first,
      POLYNOM_REVERSE => C_CFG.polynom_reverse,
      REFLECT_IN      => C_CFG.reflect_in,
      REFLECT_OUT     => C_CFG.reflect_out,
      XOR_OUT         => C_CFG.xor_out(C_CFG.width_crc-1 downto 0)
    )
    port map (
      clk_i           => clk_i,
      arst_b_i        => arst_b_i,
      sbi_ini_i       => sbi_ini,
      sbi_tgt_o       => sbi_tgt
    );

  sbi_ini.cs    <= sbi_if.cs;
  sbi_ini.addr  <= std_logic_vector(sbi_if.addr);
  sbi_ini.re    <= sbi_if.rena;
  sbi_ini.we    <= sbi_if.wena;
  sbi_ini.wdata <= sbi_if.wdata;
  sbi_if.ready  <= sbi_tgt.ready;
  sbi_if.rdata  <= sbi_tgt.rdata;

  p_sequencer : process
    variable v_checks  : natural := 0;
    variable v_seed1   : positive := 17;
    variable v_seed2   : positive := 4242 + CFG;
    variable v_crc     : t_slv16;  -- model raw register
    variable v_exp     : t_slv16;
    variable v_old     : t_slv16;
    variable v_init    : t_slv16;
    variable v_word    : t_slv16;
    variable v_len     : natural;
    variable v_found   : boolean;
    variable v_rnd     : t_slv16;
    variable v_cfg8    : t_crc_cfg;

    -- Random integer in [min, max]
    procedure rand(constant min, max : in integer; variable res : out integer) is
      variable r : real;
    begin
      uniform(v_seed1, v_seed2, r);
      res := min + integer(floor(r * real(max - min + 1)));
    end procedure;

    procedure rand16(variable res : out t_slv16) is
      variable v : integer;
    begin
      rand(0, 65535, v);
      res := std_logic_vector(to_unsigned(v, 16));
    end procedure;

    procedure wr(constant addr : in unsigned; constant data : in std_logic_vector; constant msg : in string) is
    begin
      sbi_write(addr, data, msg, clk_i, sbi_if, C_SCOPE);
    end procedure;

    procedure chk(constant addr : in unsigned; constant data : in std_logic_vector; constant msg : in string) is
    begin
      sbi_check(addr, data, msg, clk_i, sbi_if, error, C_SCOPE);
      v_checks := v_checks + 1;
    end procedure;

    procedure chk_val(constant val : in std_logic_vector; constant exp : in std_logic_vector; constant msg : in string) is
    begin
      check_value(val, exp, error, msg, C_SCOPE);
      v_checks := v_checks + 1;
    end procedure;

    -- Write the seed (raw register) in crc1:crc0
    procedure dut_set(constant seed : in t_slv16; constant msg : in string) is
    begin
      wr(CRC_CRC0, seed( 7 downto 0), msg & " (crc0)");
      wr(CRC_CRC1, seed(15 downto 8), msg & " (crc1)");
    end procedure;

    -- Process one data word (data1 is always written, it must be ignored when WIDTH_DATA <= 8)
    procedure dut_word(constant word : in t_slv16; constant msg : in string) is
    begin
      wr(CRC_DATA1, word(15 downto 8), msg & " (data1)");
      wr(CRC_DATA0, word( 7 downto 0), msg & " (data0)");
    end procedure;

    -- Wait the cycle of computation, then read crc1:crc0
    procedure dut_check(constant exp : in t_slv16; constant msg : in string) is
    begin
      wait until rising_edge(clk_i);
      chk(CRC_CRC0, exp( 7 downto 0), msg & " (crc0)");
      chk(CRC_CRC1, exp(15 downto 8), msg & " (crc1)");
    end procedure;

  begin
    sbi_if   <= init_sbi_if_signals(C_ADDR_WIDTH, C_DATA_WIDTH);
    arst_b_i <= '0', '1' after 100 ns;
    wait until arst_b_i = '1';
    wait until rising_edge(clk_i);

    log(ID_LOG_HDR, "Configuration " & integer'image(CFG) & " : " & C_CFG.name &
        " WIDTH_CRC=" & integer'image(C_CFG.width_crc) & " WIDTH_DATA=" & integer'image(C_CFG.width_data), C_SCOPE);

    -------------------------------------------------------------------------
    log(ID_LOG_HDR, "T1 : Reset values", C_SCOPE);
    -------------------------------------------------------------------------
    chk(CRC_DATA0, x"00", "data0 reset value");
    chk(CRC_DATA1, x"00", "data1 reset value");
    -- Raw register is reset to 0, the read value is the final CRC of 0 (= XOR_OUT)
    v_exp := C_CFG.xor_out and mask(C_CFG.width_crc);
    chk(CRC_CRC0, v_exp( 7 downto 0), "crc0 reset value");
    chk(CRC_CRC1, v_exp(15 downto 8), "crc1 reset value");

    -------------------------------------------------------------------------
    log(ID_LOG_HDR, "T2 : Register access", C_SCOPE);
    -------------------------------------------------------------------------
    wr (CRC_DATA1, x"5A", "Write data1");
    chk(CRC_DATA1, x"5A", "Read back data1");
    wr (CRC_DATA0, x"A5", "Write data0");
    chk(CRC_DATA0, x"A5", "Read back data0");
    -- crc0/crc1 : write the raw register, read the final CRC (REFLECT_OUT then XOR_OUT),
    -- bits above WIDTH_CRC are ignored and read as 0
    for i in 0 to 3 loop
      rand16(v_word);
      dut_set(v_word, "Write random raw CRC register");
      v_exp  := dut_final(C_CFG, v_word);
      dut_check(v_exp, "Read final CRC of the written raw register");
    end loop;

    -------------------------------------------------------------------------
    log(ID_LOG_HDR, "T3 : Reference model against the catalogue check value", C_SCOPE);
    -------------------------------------------------------------------------
    if C_CFG.check_valid then
      chk_val(crc_model(C_CFG, C_CFG.ref_init, C_CHECK_MSG), C_CFG.check, "Model check value of ""123456789""");
    end if;
    if C_CFG.width_data = 16 then
      -- 16-bit words MSB first must give the same CRC as the bytes MSB first
      v_cfg8            := C_CFG;
      v_cfg8.width_data := 8;
      chk_val(crc_model(C_CFG, C_CFG.ref_init, C_CHECK_MSG16),
              crc_model(v_cfg8, C_CFG.ref_init, C_CHECK_MSG(0 to 7)),
              "Model : 16-bit words equal to 2 bytes MSB first");
    end if;

    -------------------------------------------------------------------------
    log(ID_LOG_HDR, "T4 : DUT CRC of the check message (intermediate CRC after each word)", C_SCOPE);
    -------------------------------------------------------------------------
    dut_set(dut_seed(C_CFG, C_CFG.ref_init), "Seed with the catalogue init");
    v_crc := C_CFG.ref_init;
    if C_CFG.width_data = 8 then
      for i in C_CHECK_MSG'range loop
        dut_word(C_CHECK_MSG(i), "Check message word " & integer'image(i));
        v_crc := crc_model_step(C_CFG, v_crc, C_CHECK_MSG(i));
        dut_check(crc_model_final(C_CFG, v_crc), "CRC after word " & integer'image(i));
      end loop;
      if C_CFG.check_valid then
        chk(CRC_CRC0, C_CFG.check( 7 downto 0), "Catalogue check value (crc0)");
        chk(CRC_CRC1, C_CFG.check(15 downto 8), "Catalogue check value (crc1)");
      end if;
    else
      for i in C_CHECK_MSG16'range loop
        dut_word(C_CHECK_MSG16(i), "Check message word " & integer'image(i));
        v_crc := crc_model_step(C_CFG, v_crc, C_CHECK_MSG16(i));
        dut_check(crc_model_final(C_CFG, v_crc), "CRC after word " & integer'image(i));
      end loop;
    end if;

    -------------------------------------------------------------------------
    log(ID_LOG_HDR, "T5 : Latency : result readable one cycle after the data0 write", C_SCOPE);
    -------------------------------------------------------------------------
    v_init  := C_CFG.ref_init;
    v_old   := crc_model_final(C_CFG, v_init);
    v_found := false;
    for b in 0 to 255 loop
      v_word := std_logic_vector(to_unsigned(b, 16));
      v_exp  := crc_model(C_CFG, v_init, (0 => v_word));
      if v_exp(7 downto 0) /= v_old(7 downto 0) then
        v_found := true;
        exit;
      end if;
    end loop;
    check_value(v_found, error, "Found a data word changing crc0", C_SCOPE);
    dut_set (dut_seed(C_CFG, v_init), "Seed");
    wr (CRC_DATA1, v_word(15 downto 8), "Write data1");
    wr (CRC_DATA0, v_word( 7 downto 0), "Write data0");
    -- Read access in the cycle following the data0 write : previous CRC
    chk(CRC_CRC0, v_old( 7 downto 0), "crc0 read just after the data0 write : previous value");
    -- One cycle later : new CRC
    chk(CRC_CRC0, v_exp( 7 downto 0), "crc0 read one cycle later : new value");
    chk(CRC_CRC1, v_exp(15 downto 8), "crc1 read one cycle later : new value");

    -------------------------------------------------------------------------
    log(ID_LOG_HDR, "T6 : Software write of crc0 in the update cycle has the priority", C_SCOPE);
    -------------------------------------------------------------------------
    dut_set(x"0000", "Seed 0");
    v_word := x"00A5";
    wr (CRC_DATA0, v_word(7 downto 0), "Write data0");
    wr (CRC_CRC0 , x"3C"             , "Write crc0 in the update cycle");
    -- update discarded : raw = 0x003C
    dut_check(dut_final(C_CFG, x"003C"), "Raw register = written value, update discarded");

    -------------------------------------------------------------------------
    log(ID_LOG_HDR, "T7 : " & integer'image(C_NB_MSG) & " random messages, random init, garbage in unused bits", C_SCOPE);
    -------------------------------------------------------------------------
    for m in 0 to C_NB_MSG-1 loop
      rand(1, 16, v_len);
      rand16(v_init);
      v_init := v_init and mask(C_CFG.width_crc);
      -- bits above WIDTH_CRC of the seed are ignored
      rand16(v_rnd);
      dut_set(dut_seed(C_CFG, v_init) or (v_rnd and not mask(C_CFG.width_crc)), "Random seed");
      v_crc  := v_init;
      for i in 0 to v_len-1 loop
        -- data bits above WIDTH_DATA (data1 when WIDTH_DATA = 8) are ignored
        rand16(v_word);
        dut_word(v_word, "Random word");
        v_crc  := crc_model_step(C_CFG, v_crc, v_word);
      end loop;
      dut_check(crc_model_final(C_CFG, v_crc), "Message " & integer'image(m) & " (" & integer'image(v_len) & " words)");
    end loop;

    -------------------------------------------------------------------------
    log(ID_LOG_HDR, "T8 : Asynchronous reset", C_SCOPE);
    -------------------------------------------------------------------------
    dut_set(x"FFFF", "Seed 0xFFFF");
    wr (CRC_DATA1, x"12", "Write data1");
    wr (CRC_DATA0, x"34", "Write data0");
    wait until rising_edge(clk_i);
    arst_b_i <= '0', '1' after 40 ns;
    wait for 60 ns;
    wait until rising_edge(clk_i);
    v_exp := dut_final(C_CFG, x"0000");
    chk(CRC_DATA0, x"00", "data0 after reset");
    chk(CRC_DATA1, x"00", "data1 after reset");
    chk(CRC_CRC0, v_exp( 7 downto 0), "crc0 after reset");
    chk(CRC_CRC1, v_exp(15 downto 8), "crc1 after reset");

    log(ID_LOG_HDR, "Number of checks : " & integer'image(v_checks), C_SCOPE);
    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process;

end architecture sim;
