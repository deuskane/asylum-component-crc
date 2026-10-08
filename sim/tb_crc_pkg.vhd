-------------------------------------------------------------------------------
-- Title      : tb_crc_pkg
-- Project    : CRC
-------------------------------------------------------------------------------
-- File       : tb_crc_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Configurations and reference model for tb_crc
--              * C_CRC_CFG : table of sbi_crc configurations (selected by the
--                generic CFG of tb_crc), each one linked to a CRC of the
--                standard catalogue (Rocksoft model parameters + check value)
--              * crc_model : bit-serial Rocksoft model (independent of crc_core)
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

package tb_crc_pkg is

  subtype t_slv16 is std_logic_vector(15 downto 0);
  type    t_word_array is array (natural range <>) of t_slv16;

  type t_crc_cfg is record
    name            : string(1 to 32);
    -- sbi_crc generics
    width_crc       : positive;
    width_data      : positive;
    polynom         : t_slv16;
    shift_left      : boolean;
    lsb_first       : boolean;
    polynom_reverse : boolean;
    reflect_in      : boolean;
    reflect_out     : boolean;
    xor_out         : t_slv16;
    -- true : the seed written in crc1:crc0 is the reflected catalogue init
    --        (shift right implementation of a reflected CRC)
    init_reflect    : boolean;
    -- Catalogue (Rocksoft) parameters used by the reference model
    ref_poly        : t_slv16;
    ref_init        : t_slv16;
    ref_refin       : boolean;
    ref_refout      : boolean;
    ref_xorout      : t_slv16;
    -- Catalogue check value : CRC of the ASCII string "123456789"
    check_valid     : boolean;
    check           : t_slv16;
  end record t_crc_cfg;

  type t_crc_cfg_array is array (natural range <>) of t_crc_cfg;

  function pad      (s : string) return string;

  constant C_NB_CFG  : positive := 10;
  constant C_CRC_CFG : t_crc_cfg_array(0 to C_NB_CFG-1); -- deferred (uses pad)

  -- Reflect the WIDTH LSBs of v (others bits are cleared)
  function reflect      (v : t_slv16; width : positive) return t_slv16;
  -- Mask of the WIDTH LSBs
  function mask         (width : positive) return t_slv16;

  -- Rocksoft model : one data word on the raw register
  function crc_model_step(cfg : t_crc_cfg; crc : t_slv16; word : t_slv16) return t_slv16;
  -- Rocksoft model : final value of the raw register (RefOut then XorOut)
  function crc_model_final(cfg : t_crc_cfg; crc : t_slv16) return t_slv16;
  -- Rocksoft model : CRC of a message with a given init
  function crc_model    (cfg : t_crc_cfg; init : t_slv16; words : t_word_array) return t_slv16;

  -- Value read in crc1:crc0 when the raw DUT register is raw
  function dut_final    (cfg : t_crc_cfg; raw : t_slv16) return t_slv16;
  -- Seed to write in crc1:crc0 for a catalogue init
  function dut_seed     (cfg : t_crc_cfg; init : t_slv16) return t_slv16;

  -- "123456789"
  constant C_CHECK_MSG  : t_word_array(0 to 8) := (x"0031", x"0032", x"0033", x"0034", x"0035",
                                                  x"0036", x"0037", x"0038", x"0039");
  -- "12345678" as 16-bit big endian words
  constant C_CHECK_MSG16: t_word_array(0 to 3) := (x"3132", x"3334", x"3536", x"3738");

end package tb_crc_pkg;

package body tb_crc_pkg is

  function pad (s : string) return string is
    variable res : string(1 to 32) := (others => ' ');
  begin
    res(1 to s'length) := s;
    return res;
  end function;

  function mask (width : positive) return t_slv16 is
    variable res : t_slv16 := (others => '0');
  begin
    res(width-1 downto 0) := (others => '1');
    return res;
  end function;

  function reflect (v : t_slv16; width : positive) return t_slv16 is
    variable res : t_slv16 := (others => '0');
  begin
    for i in 0 to width-1 loop
      res(i) := v(width-1-i);
    end loop;
    return res;
  end function;

  constant C_CRC_CFG : t_crc_cfg_array(0 to C_NB_CFG-1) := (
    -- 0 : CRC-8/SMBUS
    0 => (pad("CRC-8/SMBUS")          ,  8,  8, x"0007", true , false, false, false, false, x"0000", false,
                                               x"0007", x"0000", false, false, x"0000", true , x"00F4"),
    -- 1 : CRC-8/I-432-1 (ITU) : XOR_OUT
    1 => (pad("CRC-8/I-432-1")        ,  8,  8, x"0007", true , false, false, false, false, x"0055", false,
                                               x"0007", x"0000", false, false, x"0055", true , x"00A1"),
    -- 2 : CRC-16/IBM-3740 (CCITT-FALSE)
    2 => (pad("CRC-16/CCITT-FALSE")   , 16,  8, x"1021", true , false, false, false, false, x"0000", false,
                                               x"1021", x"FFFF", false, false, x"0000", true , x"29B1"),
    -- 3 : CRC-16/GENIBUS : XOR_OUT
    3 => (pad("CRC-16/GENIBUS")       , 16,  8, x"1021", true , false, false, false, false, x"FFFF", false,
                                               x"1021", x"FFFF", false, false, x"FFFF", true , x"D64E"),
    -- 4 : CRC-16/ARC, Rocksoft style : shift left, REFLECT_IN, REFLECT_OUT
    4 => (pad("CRC-16/ARC (reflect in/out)"), 16,  8, x"8005", true , false, false, true , true , x"0000", false,
                                               x"8005", x"0000", true , true , x"0000", true , x"BB3D"),
    -- 5 : CRC-16/IBM-SDLC (X-25) : REFLECT_IN, REFLECT_OUT, XOR_OUT
    5 => (pad("CRC-16/X-25")          , 16,  8, x"1021", true , false, false, true , true , x"FFFF", false,
                                               x"1021", x"FFFF", true , true , x"FFFF", true , x"906E"),
    -- 6 : CRC-16/MODBUS as instantiated in PicoSoC : shift right, poly 0xA001, LSB first
    6 => (pad("CRC-16/MODBUS (shift right)"), 16,  8, x"A001", false, true , false, false, false, x"0000", true ,
                                               x"8005", x"FFFF", true , true , x"0000", true , x"4B37"),
    -- 7 : CRC-16/ARC, shift right with POLYNOM_REVERSE and REFLECT_IN
    7 => (pad("CRC-16/ARC (shift right)") , 16,  8, x"8005", false, false, true , true , false, x"0000", true ,
                                               x"8005", x"0000", true , true , x"0000", true , x"BB3D"),
    -- 8 : CRC-5/USB : WIDTH_CRC < 8, REFLECT_IN, REFLECT_OUT, XOR_OUT
    8 => (pad("CRC-5/USB")            ,  5,  8, x"0005", true , false, false, true , true , x"001F", false,
                                               x"0005", x"001F", true , true , x"001F", true , x"0019"),
    -- 9 : CRC-16/XMODEM with 16-bit data words (WIDTH_DATA = 16)
    9 => (pad("CRC-16/XMODEM 16b data") , 16, 16, x"1021", true , false, false, false, false, x"0000", false,
                                               x"1021", x"0000", false, false, x"0000", false, x"0000")
    );

  function crc_model_step(cfg : t_crc_cfg; crc : t_slv16; word : t_slv16) return t_slv16 is
    variable v_crc  : t_slv16 := crc and mask(cfg.width_crc);
    variable v_word : t_slv16 := word and mask(cfg.width_data);
    variable v_top  : std_logic;
  begin
    if cfg.ref_refin then
      v_word := reflect(v_word, cfg.width_data);
    end if;

    -- Message bits MSB first, register shifted to the left
    for i in cfg.width_data-1 downto 0 loop
      v_top := v_crc(cfg.width_crc-1) xor v_word(i);
      v_crc := (v_crc(14 downto 0) & '0') and mask(cfg.width_crc);
      if v_top = '1' then
        v_crc := v_crc xor (cfg.ref_poly and mask(cfg.width_crc));
      end if;
    end loop;
    return v_crc;
  end function;

  function crc_model_final(cfg : t_crc_cfg; crc : t_slv16) return t_slv16 is
    variable v_crc  : t_slv16 := crc and mask(cfg.width_crc);
  begin
    if cfg.ref_refout then
      v_crc := reflect(v_crc, cfg.width_crc);
    end if;
    return (v_crc xor cfg.ref_xorout) and mask(cfg.width_crc);
  end function;

  function crc_model (cfg : t_crc_cfg; init : t_slv16; words : t_word_array) return t_slv16 is
    variable v_crc : t_slv16 := init and mask(cfg.width_crc);
  begin
    for i in words'range loop
      v_crc := crc_model_step(cfg, v_crc, words(i));
    end loop;
    return crc_model_final(cfg, v_crc);
  end function;

  function dut_final (cfg : t_crc_cfg; raw : t_slv16) return t_slv16 is
    variable v_crc  : t_slv16 := raw and mask(cfg.width_crc);
  begin
    if cfg.reflect_out then
      v_crc := reflect(v_crc, cfg.width_crc);
    end if;
    return (v_crc xor cfg.xor_out) and mask(cfg.width_crc);
  end function;

  function dut_seed (cfg : t_crc_cfg; init : t_slv16) return t_slv16 is
  begin
    if cfg.init_reflect then
      return reflect(init, cfg.width_crc);
    else
      return init and mask(cfg.width_crc);
    end if;
  end function;

end package body tb_crc_pkg;
