library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
library asylum;
use     asylum.sbi_pkg.all;

package crc_pkg is
-- [COMPONENT_INSERT][BEGIN]
component crc_core is
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
end component crc_core;

component sbi_crc is
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

end component sbi_crc;

-- [COMPONENT_INSERT][END]

end crc_pkg;
