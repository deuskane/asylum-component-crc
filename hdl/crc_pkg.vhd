library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
library asylum;
use     asylum.sbi_pkg.all;

package crc_pkg is
-- [COMPONENT_INSERT][BEGIN]
component crc_core is
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
end component crc_core;

component sbi_crc is
  generic (
    WIDTH_CRC  : positive := 16;
    WIDTH_DATA : positive :=  8;
    POLYNOM    : std_logic_vector(WIDTH_CRC-1 downto 0) := x"1021"
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
