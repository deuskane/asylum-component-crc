-------------------------------------------------------------------------------
-- Title      : sbi_crc
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : sbi_crc.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2025-11-27
-- Last update: 2025-11-29
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2025
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2025-11-27  1.0      mrosiere Created
-- 2025-11-29  1.1      mrosiere Add Generic SHIFT_LEFT, LSB_FIRST, REVERSE, REFLECT and XOR
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.numeric_std.ALL;
library asylum;
use     asylum.sbi_pkg    .all;
use     asylum.crc_pkg    .all;
use     asylum.crc_csr_pkg.all;

entity sbi_crc is
  generic (
    WIDTH_CRC       : positive := 16;
    WIDTH_DATA      : positive :=  8;
    POLYNOM         : std_logic_vector(WIDTH_CRC-1 downto 0) := x"1021";
    SHIFT_LEFT      : boolean := false;                                         -- TRUE = shift left, FALSE = shift right
    LSB_FIRST       : boolean := false;                                         -- TRUE = process LSB first, FALSE = MSB first
    POLYNOM_REVERSE : boolean := false;                                         -- TRUE = reverse polynomial bits
    REFLECT_IN      : boolean := false;                                         -- TRUE = reflect input data bits
    REFLECT_OUT     : boolean := false;                                         -- TRUE = reflect CRC output bits
    XOR_OUT         : std_logic_vector(WIDTH_CRC-1 downto 0) := (others => '0') -- XOR mask for output
  );
  port   (
    clk_i            : in    std_logic;
    arst_b_i         : in    std_logic; -- asynchronous reset

    -- Bus
    sbi_ini_i        : in    sbi_ini_t;
    sbi_tgt_o        : out   sbi_tgt_t
    );

end entity sbi_crc;

architecture rtl of sbi_crc is

  signal sw2hw       : crc_sw2hw_t;
  signal hw2sw       : crc_hw2sw_t;

  signal data        : std_logic_vector(2*CRC_DATA_WIDTH-1 downto 0);
  signal crc_sw2hw   : std_logic_vector(2*CRC_DATA_WIDTH-1 downto 0);
  signal crc_hw2sw   : std_logic_vector(2*CRC_DATA_WIDTH-1 downto 0);
  signal crc_next    : std_logic_vector(WIDTH_CRC-1 downto 0);
  
begin  -- architecture rtl

  ins_csr : crc_registers
  port map(
    clk_i            => clk_i           ,
    arst_b_i         => arst_b_i        ,
    sbi_ini_i        => sbi_ini_i       ,
    sbi_tgt_o        => sbi_tgt_o       ,
    sw2hw_o          => sw2hw           ,
    hw2sw_i          => hw2sw   
  );

  -- Get Data
  data             <= sw2hw.data1.value &
                      sw2hw.data0.value ;

  -- Get CRC
  crc_sw2hw        <= sw2hw.crc1.value &
                      sw2hw.crc0.value ;

  -- Resize CRC next
  crc_hw2sw        <= std_logic_vector(resize(unsigned(crc_next), crc_hw2sw'length));

  -- Write crc next when data0 is written
  hw2sw.crc0.we    <= sw2hw.data0.we;
  hw2sw.crc0.value <= crc_hw2sw(  CRC_DATA_WIDTH-1 downto 0);
                   
  hw2sw.crc1.we    <= sw2hw.data0.we;
  hw2sw.crc1.value <= crc_hw2sw(2*CRC_DATA_WIDTH-1 downto CRC_DATA_WIDTH);
  
  ins_crc_core : crc_core
  generic map(
    WIDTH_CRC        => WIDTH_CRC      ,
    WIDTH_DATA       => WIDTH_DATA     ,
    POLYNOM          => POLYNOM        ,
    SHIFT_LEFT       => SHIFT_LEFT     ,
    LSB_FIRST        => LSB_FIRST      ,
    POLYNOM_REVERSE  => POLYNOM_REVERSE,
    REFLECT_IN       => REFLECT_IN     ,
    REFLECT_OUT      => REFLECT_OUT    ,
    XOR_OUT          => XOR_OUT        
    )
  port map(
    d_i              => data      (WIDTH_DATA-1 downto 0),
    crc_i            => crc_sw2hw (WIDTH_CRC -1 downto 0),
    crc_next_o       => crc_next
    );
  
end architecture rtl;
