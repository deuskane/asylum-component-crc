-- Generated VHDL Module for CRC


library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library asylum;
use     asylum.CRC_csr_pkg.ALL;
library asylum;
use     asylum.csr_pkg.ALL;
library asylum;
use     asylum.sbi_pkg.all;

--==================================
-- Module      : CRC
-- Description : CSR for CRC
-- Width       : 8
--==================================
entity CRC_registers is
  port (
    -- Clock and Reset
    clk_i      : in  std_logic;
    arst_b_i   : in  std_logic;
    -- Bus
    sbi_ini_i  : in  sbi_ini_t;
    sbi_tgt_o  : out sbi_tgt_t;
    -- CSR
    sw2hw_o    : out CRC_sw2hw_t;
    hw2sw_i    : in  CRC_hw2sw_t
  );
end entity CRC_registers;

architecture rtl of CRC_registers is

  signal   sig_wcs   : std_logic;
  signal   sig_we    : std_logic;
  signal   sig_waddr : std_logic_vector(sbi_ini_i.addr'length-1 downto 0);
  signal   sig_wdata : std_logic_vector(sbi_ini_i.wdata'length-1 downto 0);
  signal   sig_wbusy : std_logic;

  signal   sig_rcs   : std_logic;
  signal   sig_re    : std_logic;
  signal   sig_raddr : std_logic_vector(sbi_ini_i.addr'length-1 downto 0);
  signal   sig_rdata : std_logic_vector(sbi_tgt_o.rdata'length-1 downto 0);
  signal   sig_rbusy : std_logic;

  signal   sig_busy  : std_logic;

  function INIT_data0
    return std_logic_vector is
    variable tmp : std_logic_vector(8-1 downto 0);
  begin  -- function INIT_data0
    tmp(7 downto 0) := "00000000"; -- value
    return tmp;
  end function INIT_data0;

  signal   data0_wcs       : std_logic;
  signal   data0_we        : std_logic;
  signal   data0_wdata     : std_logic_vector(8-1 downto 0);
  signal   data0_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   data0_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   data0_wbusy     : std_logic;

  signal   data0_rcs       : std_logic;
  signal   data0_re        : std_logic;
  signal   data0_rdata     : std_logic_vector(8-1 downto 0);
  signal   data0_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   data0_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   data0_rbusy     : std_logic;

  function INIT_data1
    return std_logic_vector is
    variable tmp : std_logic_vector(8-1 downto 0);
  begin  -- function INIT_data1
    tmp(7 downto 0) := "00000000"; -- value
    return tmp;
  end function INIT_data1;

  signal   data1_wcs       : std_logic;
  signal   data1_we        : std_logic;
  signal   data1_wdata     : std_logic_vector(8-1 downto 0);
  signal   data1_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   data1_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   data1_wbusy     : std_logic;

  signal   data1_rcs       : std_logic;
  signal   data1_re        : std_logic;
  signal   data1_rdata     : std_logic_vector(8-1 downto 0);
  signal   data1_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   data1_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   data1_rbusy     : std_logic;

  function INIT_crc0
    return std_logic_vector is
    variable tmp : std_logic_vector(8-1 downto 0);
  begin  -- function INIT_crc0
    tmp(7 downto 0) := "00000000"; -- value
    return tmp;
  end function INIT_crc0;

  signal   crc0_wcs       : std_logic;
  signal   crc0_we        : std_logic;
  signal   crc0_wdata     : std_logic_vector(8-1 downto 0);
  signal   crc0_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   crc0_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   crc0_wbusy     : std_logic;

  signal   crc0_rcs       : std_logic;
  signal   crc0_re        : std_logic;
  signal   crc0_rdata     : std_logic_vector(8-1 downto 0);
  signal   crc0_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   crc0_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   crc0_rbusy     : std_logic;

  function INIT_crc1
    return std_logic_vector is
    variable tmp : std_logic_vector(8-1 downto 0);
  begin  -- function INIT_crc1
    tmp(7 downto 0) := "00000000"; -- value
    return tmp;
  end function INIT_crc1;

  signal   crc1_wcs       : std_logic;
  signal   crc1_we        : std_logic;
  signal   crc1_wdata     : std_logic_vector(8-1 downto 0);
  signal   crc1_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   crc1_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   crc1_wbusy     : std_logic;

  signal   crc1_rcs       : std_logic;
  signal   crc1_re        : std_logic;
  signal   crc1_rdata     : std_logic_vector(8-1 downto 0);
  signal   crc1_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   crc1_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   crc1_rbusy     : std_logic;

begin  -- architecture rtl

  -- Interface 
  sig_wcs   <= sbi_ini_i.cs;
  sig_we    <= sbi_ini_i.we;
  sig_waddr <= sbi_ini_i.addr;
  sig_wdata <= sbi_ini_i.wdata;

  sig_rcs   <= sbi_ini_i.cs;
  sig_re    <= sbi_ini_i.re;
  sig_raddr <= sbi_ini_i.addr;
  sbi_tgt_o.rdata <= sig_rdata;
  sbi_tgt_o.ready <= not sig_busy;

  sig_busy  <= sig_wbusy when sig_we = '1' else
               sig_rbusy when sig_re = '1' else
               '0';

  gen_data0: if (True)
  generate
  --==================================
  -- Register    : data0
  -- Description : Data byte0 - write start crc
  -- Address     : 0x0
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : Data Byte 0
  -- Width       : 8
  --==================================


    data0_rcs     <= '1' when     (sig_raddr(CRC_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(0,CRC_ADDR_WIDTH))) else '0';
    data0_re      <= sig_rcs and sig_re and data0_rcs;
    data0_rdata   <= (
      0 => data0_rdata_sw(0), -- value(0)
      1 => data0_rdata_sw(1), -- value(1)
      2 => data0_rdata_sw(2), -- value(2)
      3 => data0_rdata_sw(3), -- value(3)
      4 => data0_rdata_sw(4), -- value(4)
      5 => data0_rdata_sw(5), -- value(5)
      6 => data0_rdata_sw(6), -- value(6)
      7 => data0_rdata_sw(7), -- value(7)
      others => '0');

    data0_wcs     <= '1' when       (sig_waddr(CRC_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(0,CRC_ADDR_WIDTH)))   else '0';
    data0_we      <= sig_wcs and sig_we and data0_wcs;
    data0_wdata   <= sig_wdata;
    data0_wdata_sw(7 downto 0) <= data0_wdata(7 downto 0); -- value
    sw2hw_o.data0.value <= data0_rdata_hw(7 downto 0); -- value

    ins_data0 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_data0
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => data0_wdata_sw
        ,sw_rd_o       => data0_rdata_sw
        ,sw_we_i       => data0_we
        ,sw_re_i       => data0_re
        ,sw_rbusy_o    => data0_rbusy
        ,sw_wbusy_o    => data0_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => data0_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.data0.re
        ,hw_sw_we_o    => sw2hw_o.data0.we
        );

  end generate gen_data0;

  gen_data0_b: if not (True)
  generate
    data0_rcs     <= '0';
    data0_rbusy   <= '0';
    data0_rdata   <= (others => '0');
    data0_wcs      <= '0';
    data0_wbusy    <= '0';
    sw2hw_o.data0.value <= "00000000";
    sw2hw_o.data0.re <= '0';
    sw2hw_o.data0.we <= '0';
  end generate gen_data0_b;

  gen_data1: if (True)
  generate
  --==================================
  -- Register    : data1
  -- Description : Data byte1
  -- Address     : 0x1
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : Data Byte 1
  -- Width       : 8
  --==================================


    data1_rcs     <= '1' when     (sig_raddr(CRC_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(1,CRC_ADDR_WIDTH))) else '0';
    data1_re      <= sig_rcs and sig_re and data1_rcs;
    data1_rdata   <= (
      0 => data1_rdata_sw(0), -- value(0)
      1 => data1_rdata_sw(1), -- value(1)
      2 => data1_rdata_sw(2), -- value(2)
      3 => data1_rdata_sw(3), -- value(3)
      4 => data1_rdata_sw(4), -- value(4)
      5 => data1_rdata_sw(5), -- value(5)
      6 => data1_rdata_sw(6), -- value(6)
      7 => data1_rdata_sw(7), -- value(7)
      others => '0');

    data1_wcs     <= '1' when       (sig_waddr(CRC_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(1,CRC_ADDR_WIDTH)))   else '0';
    data1_we      <= sig_wcs and sig_we and data1_wcs;
    data1_wdata   <= sig_wdata;
    data1_wdata_sw(7 downto 0) <= data1_wdata(7 downto 0); -- value
    sw2hw_o.data1.value <= data1_rdata_hw(7 downto 0); -- value

    ins_data1 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_data1
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => data1_wdata_sw
        ,sw_rd_o       => data1_rdata_sw
        ,sw_we_i       => data1_we
        ,sw_re_i       => data1_re
        ,sw_rbusy_o    => data1_rbusy
        ,sw_wbusy_o    => data1_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => data1_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.data1.re
        ,hw_sw_we_o    => sw2hw_o.data1.we
        );

  end generate gen_data1;

  gen_data1_b: if not (True)
  generate
    data1_rcs     <= '0';
    data1_rbusy   <= '0';
    data1_rdata   <= (others => '0');
    data1_wcs      <= '0';
    data1_wbusy    <= '0';
    sw2hw_o.data1.value <= "00000000";
    sw2hw_o.data1.re <= '0';
    sw2hw_o.data1.we <= '0';
  end generate gen_data1_b;

  gen_crc0: if (True)
  generate
  --==================================
  -- Register    : crc0
  -- Description : CRC value byte 0
  -- Address     : 0x2
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : CRC Byte 0
  -- Width       : 8
  --==================================


    crc0_rcs     <= '1' when     (sig_raddr(CRC_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(2,CRC_ADDR_WIDTH))) else '0';
    crc0_re      <= sig_rcs and sig_re and crc0_rcs;
    crc0_rdata   <= (
      0 => crc0_rdata_sw(0), -- value(0)
      1 => crc0_rdata_sw(1), -- value(1)
      2 => crc0_rdata_sw(2), -- value(2)
      3 => crc0_rdata_sw(3), -- value(3)
      4 => crc0_rdata_sw(4), -- value(4)
      5 => crc0_rdata_sw(5), -- value(5)
      6 => crc0_rdata_sw(6), -- value(6)
      7 => crc0_rdata_sw(7), -- value(7)
      others => '0');

    crc0_wcs     <= '1' when       (sig_waddr(CRC_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(2,CRC_ADDR_WIDTH)))   else '0';
    crc0_we      <= sig_wcs and sig_we and crc0_wcs;
    crc0_wdata   <= sig_wdata;
    crc0_wdata_sw(7 downto 0) <= crc0_wdata(7 downto 0); -- value
    crc0_wdata_hw(7 downto 0) <= hw2sw_i.crc0.value; -- value
    sw2hw_o.crc0.value <= crc0_rdata_hw(7 downto 0); -- value

    ins_crc0 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_crc0
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => crc0_wdata_sw
        ,sw_rd_o       => crc0_rdata_sw
        ,sw_we_i       => crc0_we
        ,sw_re_i       => crc0_re
        ,sw_rbusy_o    => crc0_rbusy
        ,sw_wbusy_o    => crc0_wbusy
        ,hw_wd_i       => crc0_wdata_hw
        ,hw_rd_o       => crc0_rdata_hw
        ,hw_we_i       => hw2sw_i.crc0.we
        ,hw_sw_re_o    => sw2hw_o.crc0.re
        ,hw_sw_we_o    => sw2hw_o.crc0.we
        );

  end generate gen_crc0;

  gen_crc0_b: if not (True)
  generate
    crc0_rcs     <= '0';
    crc0_rbusy   <= '0';
    crc0_rdata   <= (others => '0');
    crc0_wcs      <= '0';
    crc0_wbusy    <= '0';
    sw2hw_o.crc0.value <= "00000000";
    sw2hw_o.crc0.re <= '0';
    sw2hw_o.crc0.we <= '0';
  end generate gen_crc0_b;

  gen_crc1: if (True)
  generate
  --==================================
  -- Register    : crc1
  -- Description : CRC value byte 1
  -- Address     : 0x3
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : CRC Byte 1
  -- Width       : 8
  --==================================


    crc1_rcs     <= '1' when     (sig_raddr(CRC_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(3,CRC_ADDR_WIDTH))) else '0';
    crc1_re      <= sig_rcs and sig_re and crc1_rcs;
    crc1_rdata   <= (
      0 => crc1_rdata_sw(0), -- value(0)
      1 => crc1_rdata_sw(1), -- value(1)
      2 => crc1_rdata_sw(2), -- value(2)
      3 => crc1_rdata_sw(3), -- value(3)
      4 => crc1_rdata_sw(4), -- value(4)
      5 => crc1_rdata_sw(5), -- value(5)
      6 => crc1_rdata_sw(6), -- value(6)
      7 => crc1_rdata_sw(7), -- value(7)
      others => '0');

    crc1_wcs     <= '1' when       (sig_waddr(CRC_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(3,CRC_ADDR_WIDTH)))   else '0';
    crc1_we      <= sig_wcs and sig_we and crc1_wcs;
    crc1_wdata   <= sig_wdata;
    crc1_wdata_sw(7 downto 0) <= crc1_wdata(7 downto 0); -- value
    crc1_wdata_hw(7 downto 0) <= hw2sw_i.crc1.value; -- value
    sw2hw_o.crc1.value <= crc1_rdata_hw(7 downto 0); -- value

    ins_crc1 : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_crc1
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => crc1_wdata_sw
        ,sw_rd_o       => crc1_rdata_sw
        ,sw_we_i       => crc1_we
        ,sw_re_i       => crc1_re
        ,sw_rbusy_o    => crc1_rbusy
        ,sw_wbusy_o    => crc1_wbusy
        ,hw_wd_i       => crc1_wdata_hw
        ,hw_rd_o       => crc1_rdata_hw
        ,hw_we_i       => hw2sw_i.crc1.we
        ,hw_sw_re_o    => sw2hw_o.crc1.re
        ,hw_sw_we_o    => sw2hw_o.crc1.we
        );

  end generate gen_crc1;

  gen_crc1_b: if not (True)
  generate
    crc1_rcs     <= '0';
    crc1_rbusy   <= '0';
    crc1_rdata   <= (others => '0');
    crc1_wcs      <= '0';
    crc1_wbusy    <= '0';
    sw2hw_o.crc1.value <= "00000000";
    sw2hw_o.crc1.re <= '0';
    sw2hw_o.crc1.we <= '0';
  end generate gen_crc1_b;

  sig_wbusy <= 
    data0_wbusy when data0_wcs = '1' else
    data1_wbusy when data1_wcs = '1' else
    crc0_wbusy when crc0_wcs = '1' else
    crc1_wbusy when crc1_wcs = '1' else
    '0'; -- Bad Address, no busy
  sig_rbusy <= 
    data0_rbusy when data0_rcs = '1' else
    data1_rbusy when data1_rcs = '1' else
    crc0_rbusy when crc0_rcs = '1' else
    crc1_rbusy when crc1_rcs = '1' else
    '0'; -- Bad Address, no busy
  sig_rdata <= 
    data0_rdata when data0_rcs = '1' else
    data1_rdata when data1_rcs = '1' else
    crc0_rdata when crc0_rcs = '1' else
    crc1_rdata when crc1_rcs = '1' else
    (others => '0'); -- Bad Address, return 0
end architecture rtl;
