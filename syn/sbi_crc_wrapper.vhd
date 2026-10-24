-------------------------------------------------------------------------------
-- Title      : sbi_crc_wrapper
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : sbi_crc_wrapper.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description:
-- Wrapper (lint_ghdl, lint_ghdl_synth_*) : sbi_crc with flat and
-- constrained ports (sbi_crc has unconstrained SBI ports and cannot be a
-- synthesis top). SBI address / data width : SBI_ADDR_WIDTH / SBI_DATA_WIDTH.
-- The generics of sbi_crc are forwarded (except NAME : only in sbi_tgt.info,
-- not connected).
-- POLYNOM and XOR_OUT are unconstrained (length WIDTH_CRC) : with GHDL
-- 6.0.0, the override (-g) of a generic whose subtype depends on another
-- generic fails at elaboration (NULL access) when it is forwarded to an
-- instance.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-20  1.0      mrosiere Created
-- 2026-10-24  1.1      mrosiere Was sbi_crc_synth_top, library asylum
--                               POLYNOM and XOR_OUT unconstrained
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
library asylum;
use     asylum.sbi_pkg.all;

entity sbi_crc_wrapper is
  generic (
    WIDTH_CRC       : positive := 16;
    WIDTH_DATA      : positive :=  8;
    POLYNOM         : std_logic_vector := x"1021";
    SHIFT_LEFT      : boolean  := false;
    LSB_FIRST       : boolean  := false;
    POLYNOM_REVERSE : boolean  := false;
    REFLECT_IN      : boolean  := false;
    REFLECT_OUT     : boolean  := false;
    XOR_OUT         : std_logic_vector := x"0000"
  );
  port (
    clk_i         : in  std_logic;
    arst_b_i      : in  std_logic;

    -- Bus (SBI)
    cs_i          : in  std_logic;
    re_i          : in  std_logic;
    we_i          : in  std_logic;
    addr_i        : in  std_logic_vector(SBI_ADDR_WIDTH-1 downto 0);
    wdata_i       : in  std_logic_vector(SBI_DATA_WIDTH-1 downto 0);
    ready_o       : out std_logic;
    rdata_o       : out std_logic_vector(SBI_DATA_WIDTH-1 downto 0)
  );
end entity sbi_crc_wrapper;

architecture rtl of sbi_crc_wrapper is

  signal sbi_ini       : sbi_ini_t(addr (SBI_ADDR_WIDTH-1 downto 0),
                                   wdata(SBI_DATA_WIDTH-1 downto 0));
  signal sbi_tgt       : sbi_tgt_t(rdata(SBI_DATA_WIDTH-1 downto 0));

begin

  sbi_ini.cs        <= cs_i;
  sbi_ini.re        <= re_i;
  sbi_ini.we        <= we_i;
  sbi_ini.addr      <= addr_i;
  sbi_ini.wdata     <= wdata_i;
  ready_o           <= sbi_tgt.ready;
  rdata_o           <= sbi_tgt.rdata;

  ins_sbi_crc : entity asylum.sbi_crc
    generic map (
      WIDTH_CRC       => WIDTH_CRC,
      WIDTH_DATA      => WIDTH_DATA,
      POLYNOM         => POLYNOM,
      SHIFT_LEFT      => SHIFT_LEFT,
      LSB_FIRST       => LSB_FIRST,
      POLYNOM_REVERSE => POLYNOM_REVERSE,
      REFLECT_IN      => REFLECT_IN,
      REFLECT_OUT     => REFLECT_OUT,
      XOR_OUT         => XOR_OUT
    )
    port map (
      clk_i           => clk_i,
      arst_b_i        => arst_b_i,
      sbi_ini_i       => sbi_ini,
      sbi_tgt_o       => sbi_tgt
    );

end architecture rtl;
