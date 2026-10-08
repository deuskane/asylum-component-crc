-------------------------------------------------------------------------------
-- Title      : sbi_crc
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : sbi_crc.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2025-11-27
-- Last update: 2026-10-05
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
-- 2026-10-05  1.2      mrosiere Fix multi-word CRC with REFLECT_OUT / XOR_OUT :
--                               the raw CRC register is kept in sbi_crc
--                               (crc0/crc1 are "ext" CSR), the final CRC
--                               (REFLECT_OUT then XOR_OUT) is only applied on
--                               the read path. Check WIDTH_CRC/WIDTH_DATA <= 16
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
    NAME            : string  := "";
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
  signal crc_r       : std_logic_vector(2*CRC_DATA_WIDTH-1 downto 0); -- Raw CRC register
  signal crc_next    : std_logic_vector(WIDTH_CRC-1 downto 0);        -- Raw CRC register after data
  signal crc_final   : std_logic_vector(WIDTH_CRC-1 downto 0);        -- Final CRC (REFLECT_OUT then XOR_OUT)
  signal crc_hw2sw   : std_logic_vector(2*CRC_DATA_WIDTH-1 downto 0);
  
begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- Parameters checks
  -----------------------------------------------------------------------------
  assert WIDTH_CRC  <= 2*CRC_DATA_WIDTH
    report "sbi_crc : WIDTH_CRC ("&integer'image(WIDTH_CRC)&") must be <= "&integer'image(2*CRC_DATA_WIDTH)&" (crc1:crc0)"
    severity failure;

  assert WIDTH_DATA <= 2*CRC_DATA_WIDTH
    report "sbi_crc : WIDTH_DATA ("&integer'image(WIDTH_DATA)&") must be <= "&integer'image(2*CRC_DATA_WIDTH)&" (data1:data0)"
    severity failure;

  ins_csr : crc_registers
  generic map(
    MODULE_NAME      => NAME
    )
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

  -----------------------------------------------------------------------------
  -- Raw CRC register
  -- * Software write of crc0 / crc1 : set the register (seed)
  -- * One cycle after the software write of data0 : next CRC
  --   (software write has the priority)
  -----------------------------------------------------------------------------
  process(clk_i, arst_b_i) is
  begin
    if arst_b_i = '0'
    then
      crc_r <= (others => '0');
    elsif rising_edge(clk_i)
    then
      if sw2hw.crc0.we = '1' or sw2hw.crc1.we = '1'
      then
        if sw2hw.crc0.we = '1'
        then
          crc_r(  CRC_DATA_WIDTH-1 downto              0) <= sw2hw.crc0.value;
        end if;
        if sw2hw.crc1.we = '1'
        then
          crc_r(2*CRC_DATA_WIDTH-1 downto CRC_DATA_WIDTH) <= sw2hw.crc1.value;
        end if;
      elsif sw2hw.data0.we = '1'
      then
        crc_r <= std_logic_vector(resize(unsigned(crc_next), crc_r'length));
      end if;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Read path : final CRC
  -----------------------------------------------------------------------------
  crc_hw2sw        <= std_logic_vector(resize(unsigned(crc_final), crc_hw2sw'length));

  hw2sw.crc0.we    <= '0'; -- unused by csr_ext
  hw2sw.crc0.value <= crc_hw2sw(  CRC_DATA_WIDTH-1 downto 0);
                   
  hw2sw.crc1.we    <= '0'; -- unused by csr_ext
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
    crc_i            => crc_r     (WIDTH_CRC -1 downto 0),
    crc_next_o       => crc_next  ,
    crc_o            => crc_final 
    );
  
end architecture rtl;
