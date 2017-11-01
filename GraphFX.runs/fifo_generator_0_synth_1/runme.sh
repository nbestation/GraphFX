#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/mnt/sda2/lxc/opt/SDK/2017.2/bin:/mnt/sda2/lxc/opt/Vivado/2017.2/ids_lite/ISE/bin/lin64:/mnt/sda2/lxc/opt/Vivado/2017.2/bin
else
  PATH=/mnt/sda2/lxc/opt/SDK/2017.2/bin:/mnt/sda2/lxc/opt/Vivado/2017.2/ids_lite/ISE/bin/lin64:/mnt/sda2/lxc/opt/Vivado/2017.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/mnt/sda2/lxc/opt/Vivado/2017.2/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/mnt/sda2/lxc/opt/Vivado/2017.2/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/mnt/sda2/new-home/hirayaku/Xilinx/GraphFX/GraphFX.runs/fifo_generator_0_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log fifo_generator_0.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source fifo_generator_0.tcl
