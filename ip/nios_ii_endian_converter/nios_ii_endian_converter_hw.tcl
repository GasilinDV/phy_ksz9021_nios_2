# TCL File Generated by Component Editor 9.0
# Fri Aug 14 15:43:33 GMT+08:00 2009
# DO NOT MODIFY


# +-----------------------------------
# | 
# | nios_ii_endian_converter "Nios II Endian Converter" v1.0
# | null 2009.08.14.15:43:33
# | 
# | 
# | C:/works/endian_converter/standard/ip/nios_ii_endian_converter.v
# | 
# |    ./nios_ii_endian_converter.v syn, sim
# | 
# +-----------------------------------


# +-----------------------------------
# | module nios_ii_endian_converter
# | 
set_module_property NAME nios_ii_endian_converter
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP ""
set_module_property DISPLAY_NAME "Nios II Endian Converter"
set_module_property TOP_LEVEL_HDL_FILE nios_ii_endian_converter.v
set_module_property TOP_LEVEL_HDL_MODULE nios_ii_endian_converter
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file nios_ii_endian_converter.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point nios_custom_instruction_slave_0
# | 
add_interface nios_custom_instruction_slave_0 nios_custom_instruction end
set_interface_property nios_custom_instruction_slave_0 clockCycle 0
set_interface_property nios_custom_instruction_slave_0 operands 1

set_interface_property nios_custom_instruction_slave_0 ENABLED true

add_interface_port nios_custom_instruction_slave_0 ncs_dataa dataa Input 32
add_interface_port nios_custom_instruction_slave_0 ncs_n n Input 1
add_interface_port nios_custom_instruction_slave_0 ncs_result result Output 32
# | 
# +-----------------------------------
