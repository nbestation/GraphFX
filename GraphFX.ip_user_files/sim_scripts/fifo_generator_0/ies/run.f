-makelib ies/xil_defaultlib -sv \
  "/mnt/sda2/lxc/opt/Vivado/2017.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/mnt/sda2/lxc/opt/Vivado/2017.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies/xpm \
  "/mnt/sda2/lxc/opt/Vivado/2017.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../GraphFX.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0_sim_netlist.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

