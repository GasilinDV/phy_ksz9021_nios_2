# TCL File Generated by Component Editor 11.0sp1
# Sat Mar 01 08:30:17 OMST 2014
# DO NOT MODIFY


# +-----------------------------------
# | 
# | udp_tx_offload "udp_tx_offload" v1.0
# | null 2014.03.01.08:30:17
# | 
# | 
# | /home/vadik/Qdesigns/L150_220_test/ip/udp_tx_offload/udp_tx_offload.v
# | 
# |    ./udp_tx_offload.v syn, sim
# |    ./udp_payload_inserter_1stage_pipeline.v syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 11.0
# | 
package require -exact sopc 11.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module udp_tx_offload
# | 
set_module_property NAME udp_tx_offload
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME udp_tx_offload
set_module_property TOP_LEVEL_HDL_FILE udp_tx_offload.v
set_module_property TOP_LEVEL_HDL_MODULE udp_tx_offload
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property STATIC_TOP_LEVEL_MODULE_NAME ""
set_module_property FIX_110_VIP_PATH false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file udp_tx_offload.v {SYNTHESIS SIMULATION}
add_file udp_payload_inserter_1stage_pipeline.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clock clock end
set_interface_property clock clockRate 0

set_interface_property clock ENABLED true

add_interface_port clock csi_clock_clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset
# | 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT

set_interface_property reset ENABLED true

add_interface_port reset csi_clock_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point s0
# | 
add_interface s0 avalon end
set_interface_property s0 addressUnits WORDS
set_interface_property s0 associatedClock clock
set_interface_property s0 associatedReset reset
set_interface_property s0 bitsPerSymbol 8
set_interface_property s0 burstOnBurstBoundariesOnly false
set_interface_property s0 burstcountUnits WORDS
set_interface_property s0 explicitAddressSpan 0
set_interface_property s0 holdTime 0
set_interface_property s0 linewrapBursts false
set_interface_property s0 maximumPendingReadTransactions 0
set_interface_property s0 readLatency 0
set_interface_property s0 readWaitTime 1
set_interface_property s0 setupTime 0
set_interface_property s0 timingUnits Cycles
set_interface_property s0 writeWaitTime 0

set_interface_property s0 ENABLED true

add_interface_port s0 avs_s0_write write Input 1
add_interface_port s0 avs_s0_read read Input 1
add_interface_port s0 avs_s0_address address Input 4
add_interface_port s0 avs_s0_byteenable byteenable Input 4
add_interface_port s0 avs_s0_writedata writedata Input 32
add_interface_port s0 avs_s0_readdata readdata Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point src0
# | 
add_interface src0 avalon_streaming start
set_interface_property src0 associatedClock clock
set_interface_property src0 associatedReset clock_reset
set_interface_property src0 dataBitsPerSymbol 8
set_interface_property src0 errorDescriptor ""
set_interface_property src0 firstSymbolInHighOrderBits true
set_interface_property src0 maxChannel 0
set_interface_property src0 readyLatency 0

set_interface_property src0 ENABLED true

add_interface_port src0 aso_src0_valid valid Output 1
add_interface_port src0 aso_src0_ready ready Input 1
add_interface_port src0 aso_src0_data data Output 32
add_interface_port src0 aso_src0_empty empty Output 2
add_interface_port src0 aso_src0_startofpacket startofpacket Output 1
add_interface_port src0 aso_src0_endofpacket endofpacket Output 1
add_interface_port src0 aso_src0_error error Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point snk0
# | 
add_interface snk0 avalon_streaming end
set_interface_property snk0 associatedClock clock
set_interface_property snk0 associatedReset clock_reset
set_interface_property snk0 dataBitsPerSymbol 8
set_interface_property snk0 errorDescriptor ""
set_interface_property snk0 firstSymbolInHighOrderBits true
set_interface_property snk0 maxChannel 0
set_interface_property snk0 readyLatency 0

set_interface_property snk0 ENABLED true

add_interface_port snk0 asi_snk0_valid valid Input 1
add_interface_port snk0 asi_snk0_ready ready Output 1
add_interface_port snk0 asi_snk0_data data Input 32
add_interface_port snk0 asi_snk0_empty empty Input 2
add_interface_port snk0 asi_snk0_startofpacket startofpacket Input 1
add_interface_port snk0 asi_snk0_endofpacket endofpacket Input 1
add_interface_port snk0 asi_snk0_error error Input 1
# | 
# +-----------------------------------
