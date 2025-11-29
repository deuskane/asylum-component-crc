-------------------------------------------------------------------------------
-- Title      : crc_core
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : crc_core.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2025-11-27
-- Last update: 2025-11-29
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description:
-- It's a crc_core component
-------------------------------------------------------------------------------
-- Copyright (c) 2025
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2025-11-27  1.0      mrosiere Created
-- 2025-11-29  1.1      mrosiere Add Generic SHIFT_LEFT, LSB_FIRST, REVERSE, REFLECT and XOR
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.numeric_std.ALL;

library asylum;
use     asylum.logic_pkg.all;

entity crc_core is
  generic (
    WIDTH_CRC       : positive := 16;
    WIDTH_DATA      : positive := 8;
    POLYNOM         : std_logic_vector(WIDTH_CRC-1 downto 0) := x"1021";
    SHIFT_LEFT      : boolean := false;                                         -- TRUE = shift left, FALSE = shift right
    LSB_FIRST       : boolean := false;                                         -- TRUE = process LSB first, FALSE = MSB first
    POLYNOM_REVERSE : boolean := false;                                         -- TRUE = reverse polynomial bits
    REFLECT_IN      : boolean := false;                                         -- TRUE = reflect input data bits
    REFLECT_OUT     : boolean := false;                                         -- TRUE = reflect CRC output bits
    XOR_OUT         : std_logic_vector(WIDTH_CRC-1 downto 0) := (others => '0') -- XOR mask for output
  );
  port (
    d_i        : in  std_logic_vector(WIDTH_DATA-1 downto 0);
    crc_i      : in  std_logic_vector(WIDTH_CRC -1 downto 0);
    crc_next_o : out std_logic_vector(WIDTH_CRC -1 downto 0)
  );
end entity crc_core;

architecture combi_based of crc_core is
        
  -- Adjust polynomial based on POLYNOM_REVERSE
  constant POLYNOM_USED : std_logic_vector(WIDTH_CRC-1 downto 0) := mux2(POLYNOM_REVERSE,reverse_bits(POLYNOM),POLYNOM);

begin

  process(all)
    variable crc_var      : std_logic_vector(WIDTH_CRC-1 downto 0);
    variable data_var     : std_logic_vector(WIDTH_DATA-1 downto 0);
    variable bit_index    : integer;
    variable feedback_bit : std_logic;
  begin
    -- Initialize CRC register
    crc_var  := crc_i;

    -- Reflect input data if REFLECT_IN is TRUE
    data_var := reverse_bits(d_i) when REFLECT_IN else d_i;

    -- Iterate over all bits in input data
    for i in 0 to WIDTH_DATA-1
    loop
      -- Select bit order based on LSB_FIRST
      bit_index := i when LSB_FIRST else WIDTH_DATA-1 - i;

      if SHIFT_LEFT
      then
        -- SHIFT LEFT MODE: feedback is MSB
        feedback_bit := crc_var(WIDTH_CRC-1) xor data_var(bit_index);

        -- Shift left and apply polynomial if feedback bit is '1'
        if feedback_bit = '1'
        then
          crc_var := (crc_var(WIDTH_CRC-2 downto 0) & '0') xor POLYNOM_USED;
        else
          crc_var :=  crc_var(WIDTH_CRC-2 downto 0) & '0';
        end if;

      else
        -- SHIFT RIGHT MODE: feedback is LSB
        feedback_bit := crc_var(0) xor data_var(bit_index);

        -- Shift right and apply polynomial if feedback bit is '1'
        if feedback_bit = '1'
        then
          crc_var := ('0' & crc_var(WIDTH_CRC-1 downto 1)) xor POLYNOM_USED;
        else
          crc_var :=  '0' & crc_var(WIDTH_CRC-1 downto 1);
        end if;
      end if;
    end loop;

    -- Reflect CRC output if REFLECT_OUT is TRUE
    crc_var    := reverse_bits(crc_var) when REFLECT_OUT else crc_var;
    crc_next_o <= crc_var xor XOR_OUT;
  end process;
end architecture combi_based;
