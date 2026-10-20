#!/bin/bash
#-----------------------------------------------------------------------------
# Title      : Synthesis check of sbi_crc_synth_top with ghdl --synth (post_run hook)
# Project    : Asylum
#-----------------------------------------------------------------------------
# File       : ghdl_synth.sh
# Author     : mrosiere
#-----------------------------------------------------------------------------
# Description: post_run hook of the lint_ghdl_synth target (cwd = fusesoc
#              work_root, after the run step : the ghdl -m of edalize has
#              analyzed (-Wall) and elaborated the top in library work).
#              Synthesizes the top for each configuration below. Writes
#              synth_<config>.vhd (netlist) and synth_<config>.log, prints
#              the warnings of each configuration, fails if a synthesis
#              fails or infers a latch.
#-----------------------------------------------------------------------------
# Copyright (c) 2026
#-----------------------------------------------------------------------------
# Revisions  :
# Date        Version  Author   Description
# 2026-10-20  1.0      mrosiere Created
#-----------------------------------------------------------------------------

TOP=sbi_crc_synth_top
TOP_LIB=""
GHDL_OPT="--std=08 -Wall -P./asylum"

# name : generics
CONFIGS=(
    "default         : "
    "crc8_smbus      : -gWIDTH_CRC=8 -gPOLYNOM=00000111 -gSHIFT_LEFT=true"
    "crc16_modbus    : -gPOLYNOM=1010000000000001 -gLSB_FIRST=true"
    "crc16_arc_right : -gPOLYNOM=1000000000000101 -gPOLYNOM_REVERSE=true -gREFLECT_IN=true"
    "crc5_usb        : -gWIDTH_CRC=5 -gPOLYNOM=00101 -gSHIFT_LEFT=true -gREFLECT_IN=true -gREFLECT_OUT=true -gXOR_OUT=11111"
    "crc16_data16    : -gWIDTH_DATA=16 -gSHIFT_LEFT=true"
)

nb_fail=0
for config in "${CONFIGS[@]}"; do
    name=$(echo "${config%%:*}" | tr -d ' ')
    generics=${config#*:}

    # shellcheck disable=SC2086
    ghdl --synth $GHDL_OPT $TOP_LIB $generics $TOP > "synth_${name}.vhd" 2> "synth_${name}.log"
    rc=$?

    if [ $rc -ne 0 ]; then
        status="FAIL (ghdl rc=$rc)"
    elif grep -qi "latch" "synth_${name}.log"; then
        status="FAIL (latch)"
    else
        status="PASS"
    fi
    [ "$status" = "PASS" ] || nb_fail=$((nb_fail + 1))
    nb_warn=$(grep -ci "warning" "synth_${name}.log")

    printf "ghdl --synth %-16s : %s (%d warnings)\n" "$name" "$status" "$nb_warn"
    if [ "$status" != "PASS" ]; then
        sed 's/^/    /' "synth_${name}.log"
    elif [ "$nb_warn" -ne 0 ]; then
        grep -i "warning" "synth_${name}.log" | sed 's/^/    /'
    fi
done

if [ $nb_fail -ne 0 ]; then
    echo "lint_ghdl_synth : FAIL ($nb_fail / ${#CONFIGS[@]} configurations)"
    exit 1
fi
echo "lint_ghdl_synth : PASS (${#CONFIGS[@]} configurations)"
