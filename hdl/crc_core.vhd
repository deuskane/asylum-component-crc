-------------------------------------------------------------------------------
-- Title      : crc_core
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : crc_core.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2025-11-27
-- Last update: 2025-11-27
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
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.numeric_std.ALL;

entity crc_core is
  generic (
    WIDTH_CRC  : positive := 16;
    WIDTH_DATA : positive := 8;
    POLYNOM    : std_logic_vector(WIDTH_CRC-1 downto 0) := x"1021"
  );
  port (
    d_i        : in  std_logic_vector(WIDTH_DATA-1 downto 0);
    crc_i      : in  std_logic_vector(WIDTH_CRC -1 downto 0);
    crc_next_o : out std_logic_vector(WIDTH_CRC -1 downto 0)
  );
end entity crc_core;

architecture combi_based of crc_core is
begin

  process(ALL)
    variable crc_var : std_logic_vector(WIDTH_CRC-1 downto 0);
  begin
    crc_var := crc_i;

    for bit_idx in 0 to WIDTH_DATA-1
    loop
      if (crc_var(0) xor d_i(bit_idx)) = '1'
      then
        crc_var := ('0' & crc_var(WIDTH_CRC-1 downto 1)) xor POLYNOM;
      else
        crc_var :=  '0' & crc_var(WIDTH_CRC-1 downto 1);
      end if;
    end loop;

    crc_next_o <= crc_var;
    
  end process;
end architecture combi_based;
